extends CharacterBody2D

'''
Player

current_state evolution:
	starts at default. changes to a specific action when input recieved. when animation is playing,
	a timer starts. until that timer stops, the state remains in the action one. once the timer 
	timeouts, current_state is accept stack to register inputs. timeout MUST happen before the 
	animation ends. the state will remain accept_stack until the animation ends and it changes to
	default again
'''

#region scene nodes
@onready var animation = $AnimatedSprite2D
#endregion

#region states
enum states {
	DEFAULT, # when running
	JUMP,
	FRONT_KICK,
	SPIN_KICK,
	UPPERCAT,
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
				print("took an action from the stack: ", current_state)
			
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
				
		states.FRONT_KICK:
			if animation.animation != "front_kick":
				animation.play("front_kick")
				stop_jump()
				stop_gravity()
				prepare_stack()
				# return to the default status when the animation is finished
				await animation.animation_finished
				current_state = states.DEFAULT
				resume_gravity()
			
		states.SPIN_KICK:
			if animation.animation != "spin_kick":
				animation.play("spin_kick")
				stop_jump()
				stop_gravity()
				prepare_stack()
				# return to the default status when the animation is finished
				await animation.animation_finished
				current_state = states.DEFAULT
				resume_gravity()

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
	
	
#endregion
		
