extends Node

class_name Level

signal completed

@export var next_scene: PackedScene

@export var dock_scene: PackedScene

@export var player: Player

@export var dialog_box: DialogBox

@export var weather: Weather

var progress = 0
@export var minimum_seconds: int
var length = 0
var max_boat_speed = 0
var boat_speed = 0
@export var boat: Boat
@export var boat_length := 1
@export var task_list: Array[Globals.Task_type]
@export var generate_rat_hole := false
var finished = false

var end_dock: Dock

var level_stats := LevelStats.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# If no task list, autofill with rowing tasks
	if task_list.is_empty():
		for i in boat_length * 4:
			task_list.append(Globals.Task_type.ROWING_RIGHT)
	boat.initialize(boat_length, task_list)
	level_stats.length_seconds = minimum_seconds
	if not weather:
		weather = get_tree().get_first_node_in_group("weather")
	if not weather:
		print("No weather node assigned, make sure to add one to the level if weather is needed!")
	else:
		weather.rain_ticked.connect(_on_rain_ticked)

func _level_ready():
	if generate_rat_hole:
		for node in get_tree().get_nodes_in_group("rat_hole"):
			if node is RatHole:
				node.die()
		boat.spawn_rat_hole()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_level_process(delta)
	if not finished:
		progress += boat_speed * delta
		if progress >= length:
			finished = true
			boat.stop(end_dock)
			_on_finished()
		Globals.update_level_progress_percent(clamp(progress/length, 0.0, 1.0))

func _level_process(delta: float):
	pass

func _on_boat_ready() -> void:
	max_boat_speed = boat.get_max_speed()
	length = max_boat_speed * minimum_seconds
	Globals.speed_updated.connect(_boat_speed_updated)
	
	# Spawn the end dock
	var viewport_rect = get_viewport().get_visible_rect()
	var dock_spawn_point = Vector2(viewport_rect.size.x, boat.global_position.y - length - boat.max_speed)
	if end_dock:
		end_dock.queue_free()
		end_dock = null
	end_dock = spawn_dock(dock_spawn_point)
	
	Globals.set_boat(boat)
	
	_level_ready()

func _boat_speed_updated(speed: int):
	boat_speed = clamp(speed, 0, max_boat_speed)

func spawn_dock(spawn_point: Vector2):
	var new_dock = dock_scene.instantiate()
	add_child(new_dock)
	new_dock.global_position = spawn_point
	return new_dock

func _on_leak_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("leak").size() < 3:
		Globals.boat.spawn_leak()

func _on_finished():
	if $Obstacles/LeakSpawnTimer:
		$Obstacles/LeakSpawnTimer.stop()
	for rat_hole in get_tree().get_nodes_in_group("rat_hole"):
		if rat_hole is RatHole:
			rat_hole.die()
	player.input_disabled = true
	completed.emit()

func pause_play():
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	if dialog_box:
		dialog_box.process_mode = ProcessMode.PROCESS_MODE_DISABLED

func resume_play(new_mouse_mode: int = Input.MOUSE_MODE_VISIBLE):
	process_mode = ProcessMode.PROCESS_MODE_INHERIT
	if dialog_box:
		dialog_box.process_mode = ProcessMode.PROCESS_MODE_ALWAYS
		dialog_box.update_view()

func set_finish_seconds(finish_seconds: int):
	level_stats.finish_seconds = finish_seconds

func _on_rain_ticked():
	boat.spawn_puddle()
