extends CharacterBody2D

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
	"in combo" with the previous one and thus, added to the combo array. A combo stops if one of 
	the following happens:
		1. The combo matches the combo from an enemy. Therefore, the enemy is deleted and the combo
		array reseted.
		2. There is no input before the combo timer timeouts. The combo array is reseted and the 
		player loses the combo streak
	Once the "hit frame" of an animation is reached, the combo is checked with the enemy.
'''

#region scene nodes
@onready var animation = $AnimatedSprite2D
@onready var combo_timer = $ComboTimer
#endregion

#region states
enum states {
	DEFAULT, # when running
	JUMP,
	FRONT_KICK,
	SPIN_KICK,
	UPPERCUT,
	DOWNWARDS_PUNCH,
	ACCEPT_STACK, # when an action isn't finished but inputs are accepted to be executed after the current action
	DEAD, # when game over
}

var current_state = states.DEFAULT
#endregion

#region constants
# distance from the floor at which jumps can be registered and performed
const JUMP_THRESHOLD: float = 5.0

# ideally, the time that all animations take to finish (in seconds)
const ANIMATION_DURATION: float = 0.875
# amount of time before the end of an action at which we start stacking actions to be executed at 
# the end of the current action (in seconds)
const INPUT_THRESHOLD: float = 0.25 
#endregion

#region attributes
var FLOOR_LEVEL = 0.0
var JUMP_LEVEL = -45.0

var gravity_tween: Tween 
var jump_tween: Tween

var action_stack: Array = []

# Variables for combo management
var current_combo: Array[Globals.actions] = [] # holds the current combo values
var action_already_added: bool = false
#endregion

#region ready and process
func _ready():
	FLOOR_LEVEL += position.y
	JUMP_LEVEL = position.y + JUMP_LEVEL
	#Engine.time_scale = 0.25

func _physics_process(delta: float) -> void:
	match current_state:
		states.DEFAULT:
			'''
			State default: 
				there is no action being performed, user can input a new action or one will be
				picked from the action stack (if any)
				manages animation between falling and running
			'''
			# ----------------------------
			# handle gravity and jumping
			# ----------------------------
			if position.y == FLOOR_LEVEL:
				if animation.animation != "run":
					animation.play("run")
			
			# ----------------------------
			# handle actions
			# ----------------------------
			# if there are actions in the action stack, take the newest one and  clear the stack
			# if there's another action registered this frame, it is the used, as is the newest one
			if action_stack.size() > 0:
				current_state = action_stack[-1]
				action_stack = []
			
			# jump: player can jump if close enough to the floor
			if Input.is_action_just_pressed("jump") and abs(position.y - FLOOR_LEVEL) < JUMP_THRESHOLD:
				current_state = states.JUMP
			# front kick
			elif Input.is_action_just_pressed("front_kick"):
				current_state = states.FRONT_KICK
			# spin kick
			elif Input.is_action_just_pressed("spin_kick"):
				current_state = states.SPIN_KICK
			
		states.ACCEPT_STACK:
			'''
			State accept stack:
				Registers actions and places them in the stack while an animation is about to end. 
				When the state goes back to default, which will happen when the currently playing 
				animation ends, the stack is checked to execute another action
			'''
			# jump: player can jump if close enough to the floor
			if Input.is_action_just_pressed("jump") and abs(position.y - FLOOR_LEVEL) < JUMP_THRESHOLD:
				action_stack.append(states.JUMP) 
			# front kick
			elif Input.is_action_just_pressed("front_kick"):
				action_stack.append(states.FRONT_KICK) 
			# spin kick
			elif Input.is_action_just_pressed("spin_kick"):
				action_stack.append(states.SPIN_KICK) 
		
		states.JUMP:
			# perform the jump in the correct frame
			if animation.animation == "jump":
				if animation.frame == 2:
					# tween for jump
					jump_tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
					jump_tween.tween_property(self, "position", Vector2(position.x, JUMP_LEVEL), 0.25)
					# we change to default state to be able to interrupt the jump animation
					current_state = states.DEFAULT
					await jump_tween.finished
					resume_gravity()
			# play jump animation if not already playing
			else:
				animation.play("jump")
		
		# -------------------------------------
		# match for action states
		# -------------------------------------
		states.FRONT_KICK, states.SPIN_KICK, states.UPPERCUT, states.DOWNWARDS_PUNCH:
			if animation.animation != get_action_string(current_state):
				add_combo()
				animation.play(get_action_string(current_state))
				stop_jump()
				stop_gravity()
				prepare_stack()
				# return to the default status when the animation is finished
				await animation.animation_finished
				resume_gravity()
				start_combo()
				current_state = states.DEFAULT
			else:
				if animation.frame == get_hit_frame() and not action_already_added:
					check_combo()
				

	move_and_slide()
#endregion

#region utility functions
func resume_gravity() -> void:
	# the falling time will be greater the higher the player is from the ground
	# if player is at JUMP_LEVEL (highest possible), the falling time is 0.5 seconds and that times
	# decreases linearly until reaching 0s at y = FLOOR_LEVEL
	var falling_time = (position.y - abs(FLOOR_LEVEL)) / (2.0 * (abs(JUMP_LEVEL) - abs(FLOOR_LEVEL)))
	
	if falling_time > 0:
		if animation.animation != "fall":
			animation.play("fall")
	
		gravity_tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		gravity_tween.tween_property(self, "position", Vector2(position.x, FLOOR_LEVEL), falling_time)
		
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
		
func prepare_stack() -> void:
	# time to wait before start accepting actions
	await get_tree().create_timer(ANIMATION_DURATION - INPUT_THRESHOLD).timeout
	
	current_state = states.ACCEPT_STACK
	action_stack = []
	
func start_combo() -> void:
	combo_timer.start()
	
func add_combo() -> void:
	# add the action to the combo
	if is_action(current_state):
		combo_timer.stop()
		match current_state:
			states.FRONT_KICK:
				current_combo.append(Globals.actions.FRONT_KICK)
			states.SPIN_KICK:
				current_combo.append(Globals.actions.SPIN_KICK)
			states.UPPERCUT:
				current_combo.append(Globals.actions.UPPERCUT)
			states.DOWNWARDS_PUNCH:
				current_combo.append(Globals.actions.DOWNWARDS_PUNCH)
		print("action added to combo. Current combo: ", current_combo)
		
func check_combo() -> void:
	# first, check if the combo matches the enemy's combo
	if current_combo == Globals.enemy_combo:
		# manage "combo accepted"
		print("matching combo: ",current_combo)
		current_combo = []
		combo_timer.stop()
		Globals.combo_succeeded.emit()
		
# returns the string associated to the animation for the passed state
func get_action_string(state: states) -> String:
	match state:
		states.FRONT_KICK:
			return "front_kick"
		states.SPIN_KICK:
			return "spin_kick"
		states.UPPERCUT:
			return "uppercut"
		states.DOWNWARDS_PUNCH:
			return "downwards_punch"
		_:
			return ""
		
# returns true if the state is an action
func is_action(state: states) -> bool:
	if state == states.FRONT_KICK or state == states.SPIN_KICK \
	or state == states.UPPERCUT or state == states.SPIN_KICK:
		return true
	else:
		return false
		
# given the current action, returns the animation frame at which the combo is emmited
func get_hit_frame() -> int:
	match current_state:
		states.FRONT_KICK:
			return 5 
		states.SPIN_KICK:
			return 7
		states.UPPERCUT:
			return 0
		states.DOWNWARDS_PUNCH:
			return 0
		_: 
			return -1
			
#endregion
		


func _on_combo_timer_timeout() -> void:
	print("timeout for combo. Last combo state: ", current_combo)
	current_combo = []
