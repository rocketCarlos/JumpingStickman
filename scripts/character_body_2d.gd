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
	ACTION, # when performing an action, such us jumping or hitting. 
	DEAD, # when game over
}

var current_state = states.DEFAULT
#endregion

#region constants
const SPEED: float = 300.0
const JUMP_VELOCITY: float = -250.0
const GRAVITY: Vector2 = Vector2(0, 800.0)
const ACTION_FLOATING_VELOCITY: Vector2 = Vector2(0, -85.0)
#endregion

#region attributes
var floating: bool = false
var FLOOR_LEVEL = 0.0
var JUMP_LEVEL = -45.0

var gravity_tween: Tween 
#endregion

#region ready and process
func _ready():
	FLOOR_LEVEL += position.y
	JUMP_LEVEL = position.y + JUMP_LEVEL

func _physics_process(delta: float) -> void:
	match current_state:
		# default state: player can input actions
		states.DEFAULT:
			if position.y == FLOOR_LEVEL:
				if animation.animation != "run":
					animation.play("run")
					
				# handle jump
				if Input.is_action_just_pressed("jump"):
					animation.play("jump")
					current_state = states.ACTION
			elif not gravity_tween: # if not in the floor, simulate gravity
				gravity_tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
				gravity_tween.tween_property(self, "position", Vector2(position.x, FLOOR_LEVEL), 0.5)
				await gravity_tween.finished
				gravity_tween = null
			
			if Input.is_action_just_pressed("front_kick"):
				if gravity_tween:
					gravity_tween.stop()
					gravity_tween = null
			
		states.ACTION:
			if animation.animation == "jump" and animation.frame == 3:
				var v_tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
				v_tween.tween_property(self, "position", Vector2(position.x, JUMP_LEVEL), 0.25)
				await v_tween.finished
				current_state = states.DEFAULT
				
					
	# add the gravity
	'''if not is_on_floor():
		if floating:
			velocity = ACTION_FLOATING_VELOCITY
			floating = false
		else:
			velocity += GRAVITY * delta'''
			
	move_and_slide()
#endregion
	
	
