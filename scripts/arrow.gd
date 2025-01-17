extends AnimatedSprite2D

# accepts right, left, up, right
var direction: String = "up":
	set(value):
		direction = value
		if direction not in ["right", "up", "left", "down"]:
			printerr(direction, " is not a valid direction for the arrow")
# accepts static, dynamic
var type: String = "static":
	set(value):
		type = value
		if type not in ["static", "dynamic"]:
			printerr(type, " is not a valid type for the arrow")

var fps: int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed_scale = fps
	animation = direction
	if type == "static":
		frame = 10
	
	play()
		
