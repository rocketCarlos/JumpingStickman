extends Area2D

'''
Player
'''


#region scene nodes
@onready var animation = $AnimatedSprite2D
@onready var combo_timer = $ComboTimer
#endregion

#region constants
# distance from the floor at which jumps can be registered and performed
const JUMP_THRESHOLD: float = 10.0

@export var attack_scene: PackedScene
var attack_instance = null
#endregion

#region attributes
var FLOOR_LEVEL = 0.0
var JUMP_LEVEL = -37.0

var gravity_tween: Tween 
var jump_tween: Tween

# Actions waiting to be executed
var action_queue: Array[Globals.actions] = []
# Variables for combo management
var current_combo: Array[Globals.actions] = [] # holds the current combo values
# True if playing an action animation at the moment
var playing_action: bool = false
# True if the combo succeeded to avoid more action inputs
var combo_locked: bool = false
#endregion

#region ready and process
func _ready():
	FLOOR_LEVEL += position.y
	JUMP_LEVEL = position.y + JUMP_LEVEL
	#Engine.time_scale = 0.25
	
	Globals.combo_succeeded.connect(_on_combo_succeeded)
	Globals.combo_failed.connect(_on_combo_failed)
	Globals.new_enemy.connect(_on_new_enemy)

func _process(delta: float) -> void:
	# -- Action input procesing --
	if not combo_locked:
		# jump: player can jump if close enough to the floor
		if Input.is_action_just_pressed('jump') and abs(position.y - FLOOR_LEVEL) < JUMP_THRESHOLD:
			action_queue.push_back(Globals.actions.JUMP)
		# front kick
		elif Input.is_action_just_pressed('front_kick'):
			action_queue.push_back(Globals.actions.FRONT_KICK)
		# spin kick
		elif Input.is_action_just_pressed('spin_kick'):
			action_queue.push_back(Globals.actions.SPIN_KICK)
		# downwards punch
		elif Input.is_action_just_pressed('downwards_punch'):
			action_queue.push_back(Globals.actions.DOWNWARDS_PUNCH)
		# uppercut
		elif Input.is_action_just_pressed('uppercut'):
			action_queue.push_back(Globals.actions.UPPERCUT)
	elif attack_instance == null:
		if animation.frame == get_hit_frame(animation.animation):
			attack_instance = attack_scene.instantiate()
			attack_instance.global_position = global_position
			add_sibling(attack_instance)
			
	
	# -- Action animations management --
	if not playing_action and action_queue.size() > 0:
		combo_timer.stop()
		var next_action = action_queue.pop_front()
		# NOTE: play animation before emmiting signal so that animation can be
		# canceled if action is incorrect!
		animation.play(get_action_string(next_action)) 
		playing_action = true
		Globals.do_action.emit(next_action)
		if next_action != Globals.actions.JUMP: 
			stop_jump()
			stop_gravity() 
	elif animation.animation == 'jump':
		if animation.frame == 2:
			# jump logic in a function to avoid using await inside _process
			jump() 
	elif position.y == FLOOR_LEVEL and not playing_action:
		animation.play('run')
		
#endregion

#region utility functions
func jump() -> void:
	stop_jump()
	# tween for jump
	jump_tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(self, 'position', Vector2(position.x, JUMP_LEVEL), 0.25)
	await jump_tween.finished
	playing_action = false
	jump_tween = null
	resume_gravity()

func resume_gravity() -> void:
	# the falling time will be greater the higher the player is from the ground
	# if player is at JUMP_LEVEL (highest possible), the falling time is 0.5 seconds and that times
	# decreases linearly until reaching 0s at y = FLOOR_LEVEL
	var falling_time = (position.y - abs(FLOOR_LEVEL)) / (2.0 * (abs(JUMP_LEVEL) - abs(FLOOR_LEVEL)))
	
	if falling_time > 0:
		if animation.animation != 'fall':
			animation.play('fall')
	
		gravity_tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		gravity_tween.tween_property(self, 'position', Vector2(position.x, FLOOR_LEVEL), falling_time)
		
		await gravity_tween.finished
		gravity_tween = null
	

func stop_jump() -> void:
	if jump_tween:
		jump_tween.kill()
		jump_tween = null

func stop_gravity() -> void:
	if gravity_tween:
		gravity_tween.kill()
		gravity_tween = null

# returns the string associated to the animation for the passed state
func get_action_string(attack: Globals.actions) -> String:
	match attack:
		Globals.actions.FRONT_KICK:
			return 'front_kick'
		Globals.actions.SPIN_KICK:
			return 'spin_kick'
		Globals.actions.UPPERCUT:
			return 'uppercut'
		Globals.actions.DOWNWARDS_PUNCH:
			return 'downwards_punch'
		Globals.actions.JUMP:
			return 'jump'
		_:
			return ''

# given the current action, returns the animation frame at which the combo is emmited
func get_hit_frame(attack: String) -> int:
	match attack:
		'front_kick':
			return 5 
		'spin_kick':
			return 7
		'uppercut':
			return 5
		'downwards_punch':
			return 8
		_: 
			return -1
			
#endregion
		

#region signal functions
func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.

func _on_animated_sprite_2d_animation_finished() -> void:
	if animation.animation != 'jump':
		resume_gravity()
	
	'''print(Globals.actions.values())
	print(get_action_string(0), ' ', 0 in Globals.actions.values())
	print(get_action_string(1), ' ', 1 in Globals.actions.values())
	print(get_action_string(2), ' ', 2 in Globals.actions.values())
	print(get_action_string(3), ' ', 3 in Globals.actions.values())
	print(get_action_string(4), ' ', 4 in Globals.actions.values())
	print(Globals.actions.values().map(func(value): get_action_string(value)))
	if animation.animation in Globals.actions.keys().map(func(key): get_action_string(Globals.actions[key])):
		combo_timer.start()
		print('start')'''
	
	for value in Globals.actions.values():
		if get_action_string(value) == animation.animation:
			combo_timer.start()
			print('start')
		
		
	playing_action = false
	
func _on_combo_succeeded():
	combo_locked = true
	
func _on_combo_failed():
	# cancel animations and clear action queue
	action_queue.clear()
	playing_action = false
	if position.y == FLOOR_LEVEL:
		animation.play('run')
	else:
		animation.play("fall")

func _on_new_enemy():
	combo_locked = false
	attack_instance = null
	
func _on_combo_timer_timeout() -> void:
	Globals.combo_timeout.emit()
#endregion
