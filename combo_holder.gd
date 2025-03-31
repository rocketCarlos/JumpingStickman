extends Label

@onready var combo_label = $Combo

var animation_tween = create_tween()

var combo_value: int = 0:
	set(value):
		combo_value = value
		combo_label.text = str(value)

func _ready() -> void:
	do_animation()
	
func _process(delta: float) -> void:
	pivot_offset = size / 2
	pass
	
func do_animation() -> void:
	animation_tween.kill()
	animation_tween = create_tween()
	scale = Vector2(1.0, 1.0)
	
	for i in range(12):
		animation_tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.05)
		animation_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05)
		
		
