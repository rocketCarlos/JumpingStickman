extends AnimatedSprite2D

#region scene nodes
@onready var arrow_holder = $ArrowHolder
#endregion

#region scene attributes
enum types {
	MOB1,
	MOB2,
	MOB3,
	FLYING1,
	FLYING2,
	FLYING3,
	BIG,
}
var type: types

var type_combos: Dictionary = {
	types.MOB1: [Globals.actions.FRONT_KICK, Globals.actions.FRONT_KICK, Globals.actions.SPIN_KICK],
	types.MOB2: [Globals.actions.UPPERCUT, Globals.actions.SPIN_KICK, Globals.actions.FRONT_KICK],
	types.MOB3: [Globals.actions.DOWNWARDS_PUNCH, Globals.actions.UPPERCUT, Globals.actions.DOWNWARDS_PUNCH],
	types.FLYING1: [Globals.actions.SPIN_KICK, Globals.actions.DOWNWARDS_PUNCH, Globals.actions.FRONT_KICK],
	types.FLYING2: [Globals.actions.FRONT_KICK, Globals.actions.UPPERCUT, Globals.actions.UPPERCUT],
	types.FLYING3: [Globals.actions.DOWNWARDS_PUNCH, Globals.actions.SPIN_KICK, Globals.actions.UPPERCUT],
	types.BIG: [Globals.actions.FRONT_KICK, Globals.actions.UPPERCUT, Globals.actions.SPIN_KICK, Globals.actions.DOWNWARDS_PUNCH],
}
var combo: Array

const SPEED: float = -18.0
# const SPEED: float = -1.0

@export var arrow_scene: PackedScene
#endregion

#region ready and process
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# choose what enemy can be sent
	match Globals.defeated_enemies:
		0:
			type = types.MOB2
		1:
			type = types.MOB1
		2:
			type = types.MOB3
		3:
			type = types.FLYING1
		12:
			type = types.BIG
		_:
			type = types.values()[randi_range(0, types.values().size()-1)]
	
	combo = type_combos[type]
	Globals.enemy_combo = combo
	animation = get_string_from_type(type)
	play()
	
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
		types.MOB1:
			return "mob1"
		types.MOB2:
			return "mob2"
		types.MOB3:
			return "mob3"
		types.FLYING1:
			return "flying1"
		types.FLYING2:
			return "flying2"
		types.FLYING3:
			return "flying3"
		types.BIG:
			return "big"
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
