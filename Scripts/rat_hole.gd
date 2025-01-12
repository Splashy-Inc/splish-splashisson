extends Obstacle

@export var rat_scene: PackedScene

func _spawn_rat():
	var new_rat = rat_scene.instantiate()
	new_rat.died.connect(_on_rat_died.bind(new_rat))
	new_rat.hole = self
	add_child(new_rat)
	$SpawnTimer.stop()

func _on_spawn_timer_timeout() -> void:
	_spawn_rat()

func _on_rat_died(rat: Rat):
	remove_child(rat)
	$SpawnTimer.start()
