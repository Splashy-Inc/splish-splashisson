extends Node2D

class_name TaskSlot

@export var type: Globals.Task_type
@export var is_left = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_task_type(type)

func set_task_type(new_type: Globals.Task_type):
	if is_left:
		if new_type == Globals.Task_type.ROWING_RIGHT:
			new_type = Globals.Task_type.ROWING_LEFT
	elif new_type == Globals.Task_type.ROWING_LEFT:
		new_type = Globals.Task_type.ROWING_RIGHT
	
	if type != new_type:
		type = new_type
		var new_task = Globals.generate_task(type)
		if new_task is RowingTask:
			clear()
			add_child(new_task)
			return true
		else:
			print("Type provided is not a worker station, skipping this one and freeing orphan node: ", new_task)
			if new_task:
				new_task.free()
			return false
	else:
		return true

func clear():
	for child in get_children():
		if child is Task:
			child.set_worker(null)
		remove_child(child)
		child.queue_free()
