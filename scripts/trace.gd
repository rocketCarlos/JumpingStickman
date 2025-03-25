extends Sprite2D

var intensity = 0 # BETWEEN 0 AND 1
const MAX_OFFSET = -100

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + Vector2(intensity*MAX_OFFSET, 0) , 0.2)
	var r = 1
	var g = 1
	var b = 1
	if intensity > 0.1:
		if randf() < randf_range(intensity, 1):
			if randi_range(0, 2) == 0:
				r = 0
			elif randi_range(0, 1) == 0:
				g = 0
			else:
				b = 0
				
	modulate = Color(r, g, b, max(0, intensity-0.05))
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	
	await tween.finished
	queue_free()
