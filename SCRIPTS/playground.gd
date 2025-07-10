extends Level

func _level_ready():
	for node in get_tree().get_nodes_in_group("rat_hole"):
		if node is RatHole:
			node.die()
	boat.spawn_rat_hole()
