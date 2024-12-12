extends Node2D

@export var tasks: Array[Globals.Task_type]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_up_tasks()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize(tasks_to_place: Array[Globals.Task_type]):
	tasks = tasks_to_place
	_set_up_tasks()
	
func _set_up_tasks():
	# Clear tasks
	for slot in $Tasks.get_children():
		for task in slot.get_children():
			if task is Task:
				task.set_worker(null)
			task.queue_free()
	
	# Generate and place new tasks
	for task in tasks:
		var new_task = Globals.generate_task(task)
		if new_task is Task:
			for slot in $Tasks.get_children():
				if slot.get_children().is_empty():
					slot.add_child(new_task)
					new_task = null
					break
			if new_task:
				print("Unable to assign ", task, " to a slot. They may all be full. Freeing orphan node: ", $Tasks.get_children())
				new_task.free()
		else:
			print("Scene in task array is not a Task type scene, skipping this one and freeing orphan node: ", new_task)
			new_task.free()
