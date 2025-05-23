extends Node2D

@export var scene_player: PackedScene
var instance_player: Node
const POS_PLAYER = Vector2(25, 70.5)
@export var scene_spawner: PackedScene
var instance_spawner: Node
const POS_SPAWNER = Vector2(178.575, 70.5)

@onready var button_play = $Game/Play
@onready var label_score = $UIHolder/Score
@onready var background_music = $Sound/BackgroundMusic
@onready var death_sound = $Sound/DeathSound
var POS_SCORE = Vector2(924, 28)
var score = 0

@onready var SPAWN_ROOT = $Game

func _ready() -> void:
	Globals.game_start.connect(_on_game_start)
	Globals.game_end.connect(_on_game_end)
	Globals.enemy_died.connect(_on_enemy_died)
	Globals.player_defeated_animation.connect(_on_player_defeated_animation)

func _on_game_start() -> void:
	Engine.time_scale = 1
	background_music.play()
	
	instance_player = scene_player.instantiate()
	instance_player.position = POS_PLAYER - Vector2(35, 0)
	var player_tween = get_tree().create_tween()
	player_tween.tween_property(instance_player, "position", POS_PLAYER, 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	instance_spawner = scene_spawner.instantiate()
	instance_spawner.position = POS_SPAWNER
	SPAWN_ROOT.add_child(instance_player)
	SPAWN_ROOT.add_child(instance_spawner)
	
	var score_tween = get_tree().create_tween()
	score_tween.tween_property(label_score, "position", POS_SCORE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	set_score(0)
	Globals.defeated_enemies = 0
	
func _on_game_end() -> void:
	instance_player.queue_free()
	button_play.restart()
	
func _on_enemy_died() -> void:
	set_score(score + 1 + int(Globals.combo/10))

func set_score(value: int) -> void:
	score = value
	label_score.text = str(value)

func _on_player_defeated_animation() -> void:
	background_music.stop()
	death_sound.play()
	instance_spawner.queue_free()


func _on_world_limit_area_entered(area: Area2D) -> void:
	Globals.world_limit.emit()
