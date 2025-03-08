extends AnimatedSprite2D

@onready var outline_sprite = $Outline

# accepts right, left, up, right
var direction: String = "up":
	set(value):
		direction = value
		if direction not in ["right", "up", "left", "down", "jump"]:
			printerr(direction, " is not a valid direction for the arrow")
# accepts static, dynamic
var type: String = "static":
	set(value):
		type = value
		if type not in ["static", "dynamic"]:
			printerr(type, " is not a valid type for the arrow")

var outline: String = "none":
	set(value):
		outline = value
		if outline not in ["none", "green", "red", "gold"]:
			printerr(outline, " is not a valid outline for the arrow")

var fps: int = 19

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_arrow(fps, direction, type)
	
func update_arrow(speed: float = fps, dir: String = "up", t: String = "static", ol: String = "none") -> void:
	speed_scale = speed
	animation = dir
	frame = 0
	if t == "dynamic":
		play()
	if ol != 'none':
		outline_sprite.play(ol)
		outline_sprite.show()
	else:
		outline_sprite.hide()
		

#region utility functions to be used by other nodes that hold arrows
func change_outline(color: String) -> void:
	match color:
		"green":
			outline_sprite.show()
			outline_sprite.play('green')
		"gold":
			outline_sprite.show()
			outline_sprite.play('gold')
		"red":
			outline_sprite.show()
			outline_sprite.play('red')
		_:
			outline_sprite.hide()

func light() -> void:
	pass
#endregion
