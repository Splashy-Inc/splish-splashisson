extends StaticBody2D

class_name Deck

@export var tasks: Array[Globals.Task_type]
var spawn_boundary: Rect2
var task_slots: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_boundary = $SpawnArea/CollisionShape2D.shape.get_rect()
	task_slots = $TaskSlots
	_set_up_tasks()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize(tasks_to_place: Array[Globals.Task_type]):
	tasks = tasks_to_place
	
func _set_up_tasks():
	clear_deck()
	# Generate and place new tasks
	for task in tasks:
		var new_task = Globals.generate_task(task)
		if new_task is Task:
			for slot in task_slots.get_children():
				if slot.get_children().is_empty():
					slot.add_child(new_task)
					new_task = null
					break
			if new_task:
				print("Unable to assign ", new_task, " to a slot. They may all be full. Freeing orphan node: ", $Tasks.get_children())
				new_task.free()
		else:
			print("Scene in task array is not a Task type scene, skipping this one and freeing orphan node: ", new_task)
			new_task.free()

func clear_deck():
	# Clear tasks
	if task_slots:
		for slot in task_slots.get_children():
			for task in slot.get_children():
				if task is Task:
					task.set_worker(null)
				task.free()

func spawn_leak():
	var new_leak = Globals.generate_task(Globals.Task_type.LEAK)
	Globals.boat.add_obstacle(new_leak)
	var spawned_leak = new_leak.spawn(Vector2(randi_range(spawn_boundary.position.x + global_position.x, spawn_boundary.position.x + spawn_boundary.size.x + global_position.x), randi_range(spawn_boundary.position.y + global_position.y, spawn_boundary.position.y + spawn_boundary.size.y + global_position.y)))
	if spawned_leak == new_leak:
		if new_leak.global_position.x > (spawn_boundary.position.x + global_position.x + spawn_boundary.size.x/2):
			new_leak.scale.x *= -1
	else:
		spawn_leak()

func spawn_puddle(spawn_point: Vector2) -> Puddle:
	var new_puddle = Globals.generate_task(Globals.Task_type.PUDDLE)
	Globals.boat.add_obstacle(new_puddle)
	return new_puddle.spawn(spawn_point)

func is_point_in_play_space(point: Vector2):
	return Geometry2D.is_point_in_polygon(point-$PlayArea/CollisionPolygon2D.global_position, $PlayArea/CollisionPolygon2D.polygon)

func get_rowing_tasks():
	var rowing_tasks = []
	for slot in task_slots.get_children():
		for task in slot.get_children():
			if task is RowingTask:
				rowing_tasks.append(task)
	
	return rowing_tasks
