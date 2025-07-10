extends Obstacle

class_name RatHole

@export var rat_scene: PackedScene

@onready var spawn_timer: Timer = $SpawnTimer

func spawn_rat():
	if get_tree().get_node_count_in_group("rat_hole") > get_tree().get_node_count_in_group("rat"):
		var new_rat = rat_scene.instantiate()
		new_rat.died.connect(_on_rat_died.bind(new_rat))
		new_rat.hole = self
		add_child(new_rat)
		$SpawnTimer.stop()
		return new_rat
	else:
		print(self, " unable to spawn rat. Too many rats (one per rat hole allowed)")
		return null

func _on_spawn_timer_timeout() -> void:
	spawn_rat()

func _on_rat_died(rat: Rat):
	if $SpawnTimer:
		$SpawnTimer.start()

func is_targetable():
	return false

func spawn(spawn_point: Vector2):
	var spawn_occupant = _spawn("impassable", spawn_point)
	if spawn_occupant == self:
		spawn_occupant = _spawn("rat_hole", spawn_point)
		if spawn_occupant == self:
			spawn_occupant = _spawn("cargo", spawn_point)
			if spawn_occupant == self:
				spawned.emit()
	return spawn_occupant

func die():
	for child in get_children():
		if child is Rat:
			child.die()
			await child.died
		else:
			child.queue_free()
	queue_free()
