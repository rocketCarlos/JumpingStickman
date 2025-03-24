extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite

@onready var center_point = collision_shape.shape.get_rect().get_center()

var is_mouse_inside: bool = false
var disabled: bool = false 

func _process(delta: float) -> void:
	if  not disabled and (
		is_mouse_inside and Input.is_action_just_pressed("click") or 
		Input.is_action_just_pressed("ok")
		):
		do_squish_thing()
		is_mouse_inside = false
	
	if is_mouse_inside and not disabled:
		var mouse_position = get_local_mouse_position()
		var distance_to_center = max(abs(mouse_position.x - center_point.x), abs(mouse_position.y - center_point.y))
		sprite.scale = Vector2( lerpf(1.0, 0.95, inverse_lerp(15, 0, distance_to_center)), lerpf(1.0, 0.5, inverse_lerp(15, 0, distance_to_center)))
	else:
		sprite.scale = Vector2(1.0, 1.0)


func _on_mouse_entered() -> void:
	is_mouse_inside = true


func _on_mouse_exited() -> void:
	is_mouse_inside = false

func do_squish_thing() -> void:
	disabled = true
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.3, 0.3), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "modulate", Color.TRANSPARENT, 0.1)
	await tween.finished
	hide()
	Globals.game_start.emit()


func restart() -> void:
	show()
	sprite.modulate = Color.WHITE
	disabled = false
