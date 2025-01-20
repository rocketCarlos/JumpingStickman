extends AnimatedSprite2D

#region scene nodes
@onready var arrow_holder = $ArrowHolder
#endregion

#region scene attributes
enum types {
	GHOST1,
	GHOST2,
	GHOST3,
	BIG1,
	BIG2,
}
var type: types

var type_combos: Dictionary = {
	types.GHOST1: [Globals.actions.FRONT_KICK, Globals.actions.FRONT_KICK, Globals.actions.SPIN_KICK],
	types.GHOST2: [Globals.actions.UPPERCUT, Globals.actions.SPIN_KICK, Globals.actions.FRONT_KICK],
	types.GHOST3: [Globals.actions.DOWNWARDS_PUNCH, Globals.actions.UPPERCUT, Globals.actions.DOWNWARDS_PUNCH],
}
var combo: Array

const SPEED: float = -18.0
# const SPEED: float = -1.0

@export var arrow_scene: PackedScene
#endregion

#region ready and process
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# tpye = random or depending on the specific round
	type = types.GHOST1 # FOR DEBUG
	combo = type_combos[type]
	Globals.enemy_combo = combo
	animation = get_string_from_type(type)
	
	Globals.combo_succeeded.connect(_on_combo_succeeded)
	
	for action in combo:
		var arrow = arrow_scene.instantiate()
		arrow.direction = get_string_from_action(action)
		arrow.type = "static"
		arrow.fps = 5
		arrow_holder.arrow_array.append(arrow)
	
	arrow_holder.set_arrows()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += SPEED * delta
#endregion

#region utility functions
func get_string_from_type(t: types) -> String:
	match t:
		types.GHOST1:
			return "ghost1"
		types.GHOST2:
			return "ghost2"
		types.GHOST3:
			return "ghost3"
		types.BIG1:
			return "big1"
		types.BIG2:
			return "big2"
		_:
			return ""
			
func get_string_from_action(t: Globals.actions) -> String:
	match t:
		Globals.actions.FRONT_KICK:
			return "right"
		Globals.actions.SPIN_KICK:
			return "left"
		Globals.actions.UPPERCUT:
			return "up"
		Globals.actions.DOWNWARDS_PUNCH:
			return "down"
		_:
			return ""
#endregion

#region signal functions
func _on_combo_succeeded() -> void:
	# show some type of death animation
	queue_free()
#endregion
