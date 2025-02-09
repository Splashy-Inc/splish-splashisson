extends TileMapLayer

class_name PlayGrid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_task_slots() -> Array[TaskSlot]:
	var task_slots: Array[TaskSlot]
	for child in get_children():
		if child is TaskSlot:
			task_slots.append(child)
	return task_slots
