extends Node2D

@export var scene_player: PackedScene
var instance_player: Node
const POS_PLAYER = Vector2(25, 70.5)
@export var scene_spawner: PackedScene
var instance_spawner: Node
const POS_SPAWNER = Vector2(178.575, 70.5)
@onready var button_play = $Play

func _ready() -> void:
	Globals.game_start.connect(_on_game_start)
	Globals.game_end.connect(_on_game_end)
	

func _on_game_start() -> void:
	instance_player = scene_player.instantiate()
	instance_player.position = POS_PLAYER - Vector2(35, 0)
	var player_tween = get_tree().create_tween()
	player_tween.tween_property(instance_player, "position", POS_PLAYER, 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	instance_spawner = scene_spawner.instantiate()
	instance_spawner.position = POS_SPAWNER
	add_child(instance_player)
	add_child(instance_spawner)
	
func _on_game_end() -> void:
	instance_player.queue_free()
	instance_spawner.queue_free()
	button_play.restart()
