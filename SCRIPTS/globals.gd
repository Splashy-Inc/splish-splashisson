extends Node

signal speed_updated
signal boat_ready
signal cargo_condition_updated
signal cargo_items_updated
signal level_progress_percent_updated
signal level_ready
signal level_completed

var boat: Boat
var boat_speed = 0
var level: Level
var level_progress_percent = 0.0

var cargo_info = {
	"max_condition": 0,
	"condition": 0,
	"max_items": 0,
	"item_health": 0,
	"item_texture": CompressedTexture2D.new(),
}

enum Task_type {
	NONE,
	ROWING_RIGHT,
	ROWING_LEFT,
	LEAK,
	PUDDLE,
}

var task_dict = {
	Task_type.ROWING_RIGHT: load("res://SCENES/rowing_task_right.tscn"),
	Task_type.ROWING_LEFT: load("res://SCENES/rowing_task_left.tscn"),
	Task_type.LEAK: load("res://SCENES/leak.tscn"),
	Task_type.PUDDLE: load("res://SCENES/puddle.tscn"),
}

var cargo_scene := load("res://SCENES/cargo.tscn")
var crew_scene := load("res://SCENES/crew_member.tscn")

var controls_data := load("res://controls_data.tres") as ControlsData
var cur_controls := ControlsData.AVAILABLE_CONTROLS

var action_color := Color(1, 0.741, 0.196)
var crew_select_color := Color(0, 0.843, 0.196)
var disabled_modulate := Color(1, 1, 1, 0.498)
var modulate_reset := Color(1, 1, 1)
var joypad_connected := false
var joystick : JoyStick
var is_mobile = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	joypad_connected = Input.get_connected_joypads().size() > 0
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		is_mobile = true
		cur_controls = controls_data.mobile
	elif joypad_connected:
		cur_controls = controls_data.controller
	else:
		cur_controls = controls_data.keyboard_and_mouse

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not is_mobile:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			cur_controls = controls_data.controller
		elif event is InputEventKey or event is InputEventMouse:
			cur_controls = controls_data.keyboard_and_mouse

func generate_task(type: Task_type) -> Task:
	if type != Task_type.NONE:
		return task_dict[type].duplicate().instantiate()
	else:
		return null

func generate_cargo() -> Cargo:
	return cargo_scene.duplicate().instantiate()
	
func generate_crew() -> Crew:
	return crew_scene.duplicate().instantiate()

func set_boat(new_boat: Boat):
	if boat != new_boat:
		boat = new_boat
		boat_ready.emit(boat)

func set_level(new_level: Level):
	level = new_level
	if level:
		level.completed.connect(_on_level_completed)
		level_ready.emit()

func update_boat_speed(speed: int):
	boat_speed = speed
	speed_updated.emit(speed)
	
func update_cargo_condition(condition: int, max_condition: int):
	cargo_info["max_condition"] = max_condition
	cargo_info["condition"] = condition
	if level:
		level.level_stats.cargo_finish_condition = cargo_info["condition"]
		level.level_stats.cargo_max_condition = cargo_info["max_condition"]
	cargo_condition_updated.emit(cargo_info["max_condition"], cargo_info["condition"])
	
func update_cargo_items(num_items: int, item_health: int, item_texture: Texture2D):
	cargo_info["max_items"] = num_items
	cargo_info["item_health"] = item_health
	cargo_info["item_texture"] = item_texture
	cargo_items_updated.emit(cargo_info)

func update_level_progress_percent(percent: float):
	level_progress_percent = percent
	level_progress_percent_updated.emit(level_progress_percent)
	if level_progress_percent >= 1:
		level_completed.emit(level)
		
func _on_level_completed():
	level_completed.emit(level)

func _on_joy_connection_changed(device, connected):
	joypad_connected = Input.get_connected_joypads().size() > 0

func _on_puddle_spawned():
	if level:
		level.level_stats.puddles_spawned += 1
	
func _on_puddle_fixed():
	if level:
		level.level_stats.puddles_fixed += 1

func _on_leak_spawned():
	if level:
		level.level_stats.leaks_spawned += 1
	
func _on_leak_fixed():
	if level:
		level.level_stats.leaks_fixed += 1
	
func _on_rat_spawned():
	if level:
		level.level_stats.rats_spawned += 1
	
func _on_rat_fixed():
	if level:
		level.level_stats.rats_fixed += 1
