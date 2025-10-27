extends Node

signal speed_updated
signal boat_ready
signal cargo_items_updated
signal level_progress_percent_updated
signal level_ready
signal level_completed
signal settings_updated(settings: Settings)

var boat: Boat
var boat_speed = 0
var level: Level
var level_progress_percent = 0.0
var settings := Settings.new()

enum Game_mode {
	STORY,
	FREE_PLAY,
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

var rat_hole_scene := load("res://SCENES/rat_hole.tscn")

var cargo_scene := load("res://SCENES/cargo.tscn")
var cargo_item_scene := load("res://SCENES/cargo_item.tscn")
var cargo_item_scenes_dict = {
	Cargo.Cargo_type.MEAT: cargo_item_scene,
	Cargo.Cargo_type.FUR: cargo_item_scene,
	Cargo.Cargo_type.VALUABLES: cargo_item_scene,
	Cargo.Cargo_type.LIVESTOCK: cargo_item_scene,
	Cargo.Cargo_type.MEDICINE: cargo_item_scene,
	Cargo.Cargo_type.WEAPONS: cargo_item_scene,
	Cargo.Cargo_type.MEAD: cargo_item_scene,
	Cargo.Cargo_type.SIREN: load("res://SCENES/siren_cargo_item.tscn"),
}

var crew_scene := load("res://SCENES/crew_member.tscn")

var controls_data := load("res://controls_data.tres") as ControlsData
var cur_controls := ControlsData.AVAILABLE_CONTROLS

var action_color := Color(1, 0.741, 0.196)
var crew_select_color := Color(0, 0.843, 0.196)
var disabled_modulate := Color(0.369, 0.69, 0.714, 0.498)
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

func generate_rat_hole() -> RatHole:
	return rat_hole_scene.duplicate().instantiate()

func generate_cargo() -> Cargo:
	return cargo_scene.duplicate().instantiate()

func generate_cargo_item(type: Cargo.Cargo_type) -> CargoItem:
	return cargo_item_scenes_dict[type].instantiate()

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

func update_level_progress_percent(percent: float):
	level_progress_percent = percent
	level_progress_percent_updated.emit(level_progress_percent)
	if level_progress_percent >= 1:
		level_completed.emit(level)
		
func _on_level_completed():
	level_completed.emit(level)

func _on_joy_connection_changed(device, connected):
	joypad_connected = Input.get_connected_joypads().size() > 0

func update_settings(new_settings: Settings):
	settings = new_settings
	settings_updated.emit(settings)
