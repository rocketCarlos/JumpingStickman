extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play()


func _on_animation_looped() -> void:
	frame = 3

func _process(delta) -> void:
	position.x += 150.0 * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	queue_free()
