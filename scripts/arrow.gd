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

var fps: int = 19

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_arrow(fps, direction, type)
	
func update_arrow(speed: float = fps, dir: String = "up", t: String = "static") -> void:
	speed_scale = speed
	animation = dir
	
	'''
	if t == "static":
		frame = 10
	else:
		frame = 0
	'''
	frame = 0
	if t == "dynamic":
		play()
