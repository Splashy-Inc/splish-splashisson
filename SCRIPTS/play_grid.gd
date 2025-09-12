extends TileMapLayer

class_name PlayGrid

@export var boat: Boat

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
	task_slots.sort_custom(_sort_slots)
	return task_slots

func get_cargo_slots() -> Array[CargoSlot]:
	var cargo_slots: Array[CargoSlot]
	for child in get_children():
		if child is CargoSlot:
			cargo_slots.append(child)
	return cargo_slots

func spawn_leak(spawn_point: Vector2):
	var new_leak = Globals.generate_task(Globals.Task_type.LEAK)
	if new_leak is Leak:
		boat.add_obstacle(new_leak)
		var spawned_leak = new_leak.spawn(center_point_in_cell(spawn_point))
		if spawned_leak == new_leak:
			if new_leak.global_position.x > Globals.boat.global_position.x:
				new_leak.scale.x *= -1
			return new_leak
	return null

func spawn_puddle(spawn_point: Vector2) -> Puddle:
	var new_puddle = Globals.generate_task(Globals.Task_type.PUDDLE) as Puddle
	boat.add_obstacle(new_puddle)
	return new_puddle.spawn(center_point_in_cell(spawn_point))

func spawn_rat_hole(spawn_point: Vector2) -> RatHole:
	var new_rat_hole = Globals.generate_rat_hole() as RatHole
	if new_rat_hole is RatHole:
		boat.add_obstacle(new_rat_hole)
		var spawned_rat_hole = new_rat_hole.spawn(center_point_in_cell(spawn_point))
		if spawned_rat_hole == new_rat_hole:
			return new_rat_hole
	new_rat_hole.queue_free()
	return null

# Point must be global, not local
func center_point_in_cell(point: Vector2):
	return to_global(map_to_local(local_to_map(to_local(point))))

func _sort_slots(a: TaskSlot, b: TaskSlot):
	if a.global_position.y == b.global_position.y: # Same row
		if a.global_position.x < b.global_position.x: # A is to the right of B, should be later in list
			return true
	elif a.global_position.y < b.global_position.y: # A is below B, should be later in list
		return true
	return false
