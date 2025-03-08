extends AnimatedSprite2D

#region scene nodes
@onready var arrow_holder = $ArrowHolder
@onready var mobs_collision = $Hitboxes/mobs
@onready var big_collision = $Hitboxes/big
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

var type_combos: Dictionary[types, Array] = {
	types.MOB1: [Globals.actions.FRONT_KICK, Globals.actions.FRONT_KICK, Globals.actions.SPIN_KICK],
	types.MOB2: [Globals.actions.UPPERCUT, Globals.actions.SPIN_KICK, Globals.actions.FRONT_KICK],
	types.MOB3: [Globals.actions.DOWNWARDS_PUNCH, Globals.actions.UPPERCUT, Globals.actions.DOWNWARDS_PUNCH],
	types.FLYING1: [Globals.actions.JUMP, Globals.actions.DOWNWARDS_PUNCH, Globals.actions.FRONT_KICK],
	types.FLYING2: [Globals.actions.JUMP, Globals.actions.UPPERCUT, Globals.actions.UPPERCUT],
	types.FLYING3: [Globals.actions.JUMP, Globals.actions.FRONT_KICK, Globals.actions.SPIN_KICK],
	types.BIG: [Globals.actions.FRONT_KICK, Globals.actions.UPPERCUT, Globals.actions.SPIN_KICK, Globals.actions.DOWNWARDS_PUNCH],
}
var combo: Array
# current combo progress
var combo_progress: int = 0

const SPEED: float = -11.0
const FLYING_HEIGHT: float = -36.5
const BIG_HEIGHT: float = -7.5

@export var arrow_scene: PackedScene
#endregion

#region ready and process
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.new_enemy.emit()
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
			
	match type:
		types.FLYING1, types.FLYING2, types.FLYING3:
			position.y += FLYING_HEIGHT
		types.BIG:
			position.y += BIG_HEIGHT
			big_collision.set_deferred("disabled", false)
			mobs_collision.set_deferred("disabled", true) 
			
	
	combo = type_combos[type]
	Globals.enemy_combo = combo
	animation = get_string_from_type(type)
	play()
		
	for action in combo:
		var arrow = arrow_scene.instantiate()
		arrow.direction = get_string_from_action(action)
		arrow.type = "static"
		arrow.fps = 5
		arrow_holder.arrow_array.append(arrow)
	
	arrow_holder.set_arrows()
	
	Globals.do_action.connect(_on_do_action)
	Globals.combo_timeout.connect(_on_combo_timeout)

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
		Globals.actions.JUMP:
			return "jump"
		_:
			return ""
#endregion

#region signal functions
var interrupt = false
func _on_do_action(action: Globals.actions):
	if action != combo[combo_progress]:
		Globals.combo_failed.emit()
		arrow_holder.arrow_array[combo_progress].change_outline('red')
		combo_progress = 0
		
		await get_tree().create_timer(1).timeout
		
		for arrow in arrow_holder.arrow_array:
			arrow.change_outline('')
	else:
		arrow_holder.arrow_array[combo_progress].change_outline('green')
		combo_progress += 1
		if combo_progress >= combo.size():
			Globals.combo_succeeded.emit()
			for arrow in arrow_holder.arrow_array:
				arrow.change_outline('gold')
		

func _on_hitboxes_area_entered(area: Area2D) -> void:
	Globals.enemy_died.emit()
	queue_free()
	
func _on_combo_timeout() -> void:
	combo_progress = 0
	for arrow in arrow_holder.arrow_array:
			arrow.change_outline('')
#endregion
