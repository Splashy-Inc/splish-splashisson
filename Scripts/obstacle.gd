extends Task

class_name Obstacle

func spawn(spawn_point: Vector2):
	return _spawn("impassable", spawn_point)

func _spawn(group: String, spawn_point: Vector2):
	global_position = spawn_point
	var spawn_point_occupant = _check_spawn_space_occupied(group)
	if spawn_point_occupant:
		print_debug("Not spawning ", self, " at ", spawn_point, ". Already occupied by ", spawn_point_occupant)
		queue_free()
	else:
		spawn_point_occupant = self
	
	return spawn_point_occupant

func _check_spawn_space_occupied(group: String):
	var group_nodes = get_tree().get_nodes_in_group(group)
	group_nodes.erase(self)
	
	# Check if attempted self space already overlaps with a puddle
	for node in group_nodes:
		if node.has_method("get_self_polygon") and not Geometry2D.intersect_polygons(node.get_self_polygon(), get_self_polygon()).is_empty():
			return node
			break
	
	return null
