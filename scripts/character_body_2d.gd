extends CharacterBody2D

'''
Player
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
	DEAD, # when game over
}

var current_state = states.DEFAULT
#endregion

#region constants
const JUMP_VELOCITY: float = -250.0
const GRAVITY: Vector2 = Vector2(0, 800.0)

const JUMP_THRESHOLD: float = 5.0
#endregion

#region attributes
var FLOOR_LEVEL = 0.0
var JUMP_LEVEL = -45.0

var jumping: bool = false

var gravity_tween: Tween 
var jump_tween: Tween
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
				there is no action being performed, user can input a new action
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
			# jump: player can jump if close enough to the floor
			if Input.is_action_just_pressed("jump") and abs(position.y - FLOOR_LEVEL) < JUMP_THRESHOLD:
				current_state = states.JUMP
			# front kick
			elif Input.is_action_just_pressed("front_kick"):
				current_state = states.FRONT_KICK
		
		states.JUMP:
			jumping = true
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
				# return to the default status when the animation is finished
				await animation.animation_finished
				current_state = states.DEFAULT
				resume_gravity()

	move_and_slide()
#endregion
	
'''
		# default state: player can input actions
		states.DEFAULT:
			if position.y == FLOOR_LEVEL:
				if animation.animation != "run":
					animation.play("run")
					
				# handle jump
				if Input.is_action_just_pressed("jump"):
					current_state = states.ACTION
					current_action = actions.JUMP
				
			elif animation.animation != "jump" and not gravity_tween: # if not in the floor and not jumping, simulate gravity
				gravity_tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
				gravity_tween.tween_property(self, "position", Vector2(position.x, FLOOR_LEVEL), 0.5)
				await gravity_tween.finished
				gravity_tween = null
			
			# handle actions
			if Input.is_action_just_pressed("front_kick"):
				current_state = states.ACTION
				current_action = actions.FRONT_KICK
			
		states.ACTION:
			# when an action is performed (and is not a jump), 
			# delete gravity or jump tweeners to stop the motion
			if current_action != actions.JUMP:
				if gravity_tween:
					gravity_tween.stop()
					gravity_tween = null
				if jump_tween:
					jump_tween.stop()
					jump_tween = null
			
			match current_action:
				actions.JUMP:
					if animation.animation != "jump":
						animation.play("jump")
					elif animation.frame == 3 and not jump_tween: # start moving the player upwards matching the animation
						jump_tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
						jump_tween.tween_property(self, "position", Vector2(position.x, JUMP_LEVEL), 0.25)
						# we change to default state to be able to interrupt the jump animation
						current_state = states.DEFAULT
						await jump_tween.finished
						# set the sprite to the falling one
						animation.animation = "fall"
						jump_tween = null
						current_state = states.DEFAULT
				
				actions.FRONT_KICK:
					if animation.animation != "front_kick":
						animation.play("front_kick")
						await animation.animation_finished
						current_state = states.DEFAULT
						
'''

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
		print(falling_time)
		
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
		
