extends Level

func _on_leak_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("leak").size() < 3:
		Globals.boat.spawn_leak()

func _on_completed() -> void:
	$LeakSpawnTimer.stop()
