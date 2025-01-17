extends Node2D

var arrow_array: Array[Node] = []

var offset: int = 12

func set_arrows():	
	var pos = -offset/2.0 * (arrow_array.size() -1)
	for arrow in arrow_array:
		arrow.position.x = pos
		pos += offset
		if not arrow.get_parent():
			add_child(arrow)

func clear():
	arrow_array.clear()
	for child in get_children():
		child.queue_free()
