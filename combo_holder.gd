extends Label

@onready var combo_label = $Combo
@onready var timer = $Timer

@onready var animation_tween = null

var timer_time: float = 0.0


var combo_value: int = 0:
	set(value):
		combo_value = value
		combo_label.text = str(value)
		if value < 10:
			hide()
		else:
			show()
			if value == 10:
				var position_tween = create_tween()
				position = Vector2(-650.0, 40.0)
				position_tween.tween_property(self, 'position', Vector2(78.0, 40.0), 0.33).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _ready() -> void:
	Globals.combo_updated.connect(_on_combo_updated)
	timer.start()
	
func _process(delta: float) -> void:
	pivot_offset = size / 2
	
	
func update_timer() -> void:
	if combo_value > 0:
		timer_time = 1.0/((int(combo_value/100)+1))
	else:
		scale = Vector2(1, 1)
		
func _on_combo_updated() -> void:
	combo_value = Globals.combo
	if visible:
		update_timer()


func _on_timer_timeout() -> void:
	if animation_tween:
		animation_tween.kill()
	animation_tween = create_tween()
	
	var final_size = Vector2(1.0+combo_value/100.0, 1.0+combo_value/100.0)
	
	if scale == final_size:
		animation_tween.tween_property(self, "scale", Vector2(1.0, 1.0), timer_time)
	else:
		animation_tween.tween_property(self, "scale", final_size, timer_time)
	timer.start(timer_time)
	
