extends Node2D

@export var enemy_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.enemy_died.connect(_on_enemy_died)
	var enemy = enemy_scene.instantiate()
	add_child(enemy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enemy_died():
	Globals.defeated_enemies += 1
	var enemy = enemy_scene.instantiate()
	call_deferred('add_child', enemy)
	Engine.time_scale = 1 + (0.02)*Globals.combo
