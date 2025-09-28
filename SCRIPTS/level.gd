extends Node

class_name Level

signal completed

@export var stage_data := StageData.new()

@export var dock_scene: PackedScene

@export var pirate_ship_scene: PackedScene
@export var num_pirate_ships : int
@export var start_pirates_per_ship := 1

@export var seagull_scene: PackedScene
@export var seagull_spawn: PathFollow2D
@export var seagull_spawn_interval := 0

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
@export var cargo_list: Array[CargoItemData]
@export var num_rat_holes := 0
@export var rat_spawn_interval := 10
var finished = false

var end_dock: Dock

var level_stats := LevelStats.new()

@onready var obstacles: Node = $Obstacles
@onready var remaining_pirate_ships := num_pirate_ships
@onready var seagull_spawn_timer: Timer = $Obstacles/SeagullSpawnTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for level in get_tree().get_nodes_in_group("level"):
		if level != self:
			level.queue_free()
	load_stage_data(stage_data)

func _level_ready():
	# TODO: Spawn as many rat holes as configured
	for node in get_tree().get_nodes_in_group("rat_hole"):
			if node is RatHole:
				node.die()
	if num_rat_holes > 0:
		var new_rat_hole = boat.spawn_rat_hole()
		if new_rat_hole:
			new_rat_hole.initialize(rat_spawn_interval)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_level_process(delta)
	if not finished:
		progress += boat_speed * delta
		if progress >= length:
			finished = true
			boat.stop(end_dock)
			_on_finished()
		elif remaining_pirate_ships > 0 and progress >= (length/(num_pirate_ships+1))*(num_pirate_ships - (remaining_pirate_ships - 1)):
			spawn_pirate_ship()
		Globals.update_level_progress_percent(clamp(progress/length, 0.0, 1.0))

func _level_process(delta: float):
	pass

func load_stage_data(new_stage_data: StageData):
	minimum_seconds = new_stage_data.length_seconds
	boat_length = new_stage_data.boat_length
	task_list = new_stage_data.boat_task_list
	cargo_list = new_stage_data.cargo_list
	weather.set_type(new_stage_data.weather)
	num_rat_holes = new_stage_data.num_rat_holes
	rat_spawn_interval = new_stage_data.rat_interval_seconds
	seagull_spawn_interval = new_stage_data.seagull_interval_seconds
	num_pirate_ships = new_stage_data.num_pirate_ships
	remaining_pirate_ships = num_pirate_ships
	start_pirates_per_ship = new_stage_data.start_pirates
	
	load_level()

func load_level():
	# If no task list, autofill with rowing tasks
	if task_list.is_empty():
		for i in boat_length * 4:
			task_list.append(Globals.Task_type.ROWING_RIGHT)
	boat.initialize(boat_length, task_list, cargo_list)
	
	level_stats = LevelStats.new()
	level_stats.level_name = stage_data.level_stats.level_name
	level_stats.length_seconds = minimum_seconds
	level_stats.speed_success_modifier = stage_data.level_stats.speed_success_modifier
	
	if not weather:
		weather = get_tree().get_first_node_in_group("weather")
	if not weather:
		print("No weather node assigned, make sure to add one to the level if weather is needed!")
	else:
		weather.rain_ticked.connect(_on_rain_ticked)
	
	if is_instance_valid(seagull_spawn_timer):
		if seagull_spawn_interval > 0:
			seagull_spawn_timer.start(seagull_spawn_interval)
		else:
			seagull_spawn_timer.stop()

func initialize(new_stage_data: StageData):
	stage_data = new_stage_data
	if is_node_ready():
		load_stage_data(stage_data)

func _on_boat_ready() -> void:
	max_boat_speed = boat.get_max_speed()
	length = max_boat_speed * minimum_seconds
	if not Globals.speed_updated.is_connected(_boat_speed_updated):
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
	if level_stats.calculate_success_percentage() > stage_data.level_stats.success_percentage:
		level_stats.level_name = stage_data.level_stats.level_name
		stage_data.level_stats.overwrite(level_stats)
	
	if $Obstacles/LeakSpawnTimer:
		$Obstacles/LeakSpawnTimer.stop()
	for rat_hole in get_tree().get_nodes_in_group("rat_hole"):
		if rat_hole is RatHole:
			rat_hole.die()
	player.input_disabled = true
	
	if not self is Tutorial:
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

func spawn_pirate_ship():
	# Disallow spawning pirate ship if one already exists
	#   This will help keep the player from being overwhelmed by pirates
	#   Also, that way we don't have to add in handling for multiple pirates ships existing at once
	for child in obstacles.get_children():
		if child is PirateShip:
			remaining_pirate_ships -= 1
			return
	
	var new_pirate_ship := pirate_ship_scene.instantiate() as PirateShip
	obstacles.add_child(new_pirate_ship)
	new_pirate_ship.initialize(boat, start_pirates_per_ship)
	start_pirates_per_ship += 1
	remaining_pirate_ships -= 1

func spawn_seagull():
	if is_instance_valid(seagull_spawn):
		seagull_spawn.progress_ratio = randf_range(0.0, 1.0)
		var new_seagull = seagull_scene.instantiate()
		new_seagull.global_position = seagull_spawn.global_position
		obstacles.add_child(new_seagull)

func _on_stat_entity_spawned(entity):
	if entity is Puddle:
		level_stats.puddles_spawned += 1
	elif entity is Leak:
		level_stats.leaks_spawned += 1
	elif entity is Rat:
		level_stats.rats_spawned += 1
	elif entity is Seagull:
		level_stats.seagulls_spawned += 1
	elif entity is Pirate:
		level_stats.pirates_spawned += 1

func _on_stat_entity_died(entity):
	if entity is Puddle:
		level_stats.puddles_fixed += 1
	elif entity is Leak:
		level_stats.leaks_fixed += 1
	elif entity is Rat:
		level_stats.rats_fixed += 1
	elif entity is Seagull:
		level_stats.seagulls_fixed += 1
	elif entity is Pirate:
		level_stats.pirates_fixed += 1
