extends Obstacle

class_name Leak

signal died

var is_patched = false

var current_puddle: Puddle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var level = get_tree().get_nodes_in_group("level").front() as Level
	spawned.connect(level._on_stat_entity_spawned.bind(self))
	died.connect(level._on_stat_entity_died.bind(self))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_assignee(new_assignee: Worker) -> bool:
	if is_patched or (new_assignee and assignee):
		return false
	else:
		assignee = new_assignee
		return true

# This function is intended to be set when the respective worker is in range of the task to begin work
func set_worker(new_worker: Worker) -> bool:
	if not new_worker:
		set_assignee(new_worker)
	elif new_worker != assignee:
		return false
	worker = new_worker
	return true

func patch():
	is_patched = true
	$PuddleTimer.stop()
	$AnimationTree.set("parameters/conditions/is_patched", true)
	set_worker(null)

func _die():
	remove_from_group("leak")
	died.emit()
	if is_patched:
		await $AnimationTree.animation_finished
		
	queue_free()
	
func _start_puddle_timer():
	$PuddleTimer.start()

func _on_puddle_timer_timeout() -> void:
	if not current_puddle:
		current_puddle = Globals.boat.spawn_puddle($PuddleSpawnPoint.global_position)
		if current_puddle:
			current_puddle.died.connect(_on_current_puddle_died)
	else:
		current_puddle.increase_stage()
		
func _on_current_puddle_died():
	current_puddle = null

func _start_leak():
	$SFXManager.play("Active")

func spawn(spawn_point: Vector2):
	var spawn_occupant = _spawn("impassable", spawn_point)
	if spawn_occupant == self:
		spawn_occupant = _spawn("leak", spawn_point)
		if spawn_occupant == self:
			spawned.emit()
	return spawn_occupant

func is_targetable():
	return not (is_patched or assignee)
