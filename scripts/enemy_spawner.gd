extends Node2D

@export var enemy_scene: PackedScene

'''
spawn idea: mob has a function called "initialize" that takes one argument: the number of mobs
already spawned. Depending on that number, the enemy will be different. For example:
	first 20 enemies are normal
	then some slendermans come
	then some enemies have question mark combos
	etc
'''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.combo_succeeded.connect(_on_combo_succeeded)
	var enemy = enemy_scene.instantiate()
	add_child(enemy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_combo_succeeded():
	Globals.defeated_enemies += 1
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	Engine.time_scale += 0.02
