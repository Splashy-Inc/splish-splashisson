extends Node2D

@export var tasks: Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for task in tasks:
		var new_task = task.instantiate()
		if new_task is Task:
			for slot in $Tasks.get_children():
				if slot.get_children().is_empty():
					slot.add_child(new_task)
					new_task = null
					break
			if new_task:
				print("Unable to assign ", task, " to a slot. They may all be full: ", $Tasks.get_children())
		else:
			print("Scene in task array is not a Task type scene, skipping this one: ", new_task)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
