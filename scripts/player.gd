extends Area2D

'''
Player

current_state evolution:
	starts at default. changes to a specific action when input recieved. when animation is playing,
	a timer starts. until that timer stops, the state remains in the action one. once the timer 
	timeouts, current_state is accept stack to register inputs. timeout MUST happen before the 
	animation ends. the state will remain accept_stack until the animation ends and it changes to
	default again
	
combo building:
	when an action is performed, it is added to the combo array. Once the animation is finished,
	the combo timer starts. If another one is executed before it timeouts, the action is considered
	'in combo' with the previous one and thus, added to the combo array. A combo stops if one of 
	the following happens:
		1. The combo matches the combo from an enemy. Therefore, the enemy is deleted and the combo
		array reseted.
		2. There is no input before the combo timer timeouts. The combo array is reseted and the 
		player loses the combo streak
	Once the 'hit frame' of an animation is reached, the combo is checked with the enemy.
'''

'''
evaluate idea: some mech to 'cancel' the action queue so player doesn't have to wait until all
animations are ended to start building up the combo again
'''


#region scene nodes
@onready var animation = $AnimatedSprite2D
@onready var combo_timer = $ComboTimer
@onready var arrow_holder = $ArrowHolder
#endregion

#region constants
# distance from the floor at which jumps can be registered and performed
const JUMP_THRESHOLD: float = 10.0

@export var arrow_scene: PackedScene
const ARROW_FPS: float = 19

@export var attack_scene: PackedScene
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
	
	# -- Action animations management --
	if not playing_action and action_queue.size() > 0:
		var next_action = action_queue.pop_front()
		animation.play(get_action_string(next_action)) 
		playing_action = true
		if next_action != Globals.actions.JUMP: 
			stop_jump()
			stop_gravity() 
	elif animation.animation == 'jump':
		if animation.frame == 2:
			# jump logic in a function to avoid using await inside _process
			jump() 
	elif position.y == FLOOR_LEVEL:
		animation.play('run')
		
#endregion

#region utility functions
func jump() -> void:
	stop_jump()
	# tween for jump
	jump_tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(self, 'position', Vector2(position.x, JUMP_LEVEL), 0.25)
	# set to false to enable animation cancel while jumping
	playing_action = false
	await jump_tween.finished
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
		
	
func add_arrow(st: Globals.actions, type: String):
	var arrow = arrow_scene.instantiate()
	arrow.direction = get_arrow_string(st)
	arrow.type = type
	arrow.fps = ARROW_FPS
	arrow_holder.arrow_array.append(arrow)
	
	arrow_holder.set_arrows()
		

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

# returns the string associated to the arrow direction that triggers the action
func get_arrow_string(attack: Globals.actions) -> String:
	match attack:
		Globals.actions.FRONT_KICK:
			return 'right'
		Globals.actions.SPIN_KICK:
			return 'left'
		Globals.actions.UPPERCUT:
			return 'up'
		Globals.actions.DOWNWARDS_PUNCH:
			return 'down'
		_:
			return ''

# given the current action, returns the animation frame at which the combo is emmited
func get_hit_frame(attack: Globals.actions) -> int:
	match attack:
		Globals.actions.FRONT_KICK:
			return 5 
		Globals.actions.SPIN_KICK:
			return 7
		Globals.actions.UPPERCUT:
			return 5
		Globals.actions.DOWNWARDS_PUNCH:
			return 8
		_: 
			return -1
			
#endregion
		

#region signal functions
func _on_combo_timer_timeout() -> void:
	current_combo = []
	arrow_holder.clear()
	

func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
#endregion


func _on_animated_sprite_2d_animation_finished() -> void:
	if animation.animation != 'jump':
		resume_gravity()
	playing_action = false
