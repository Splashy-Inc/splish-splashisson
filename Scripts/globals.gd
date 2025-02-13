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
	Task_type.ROWING_RIGHT: load("res://Scenes/rowing_task_right.tscn"),
	Task_type.ROWING_LEFT: load("res://Scenes/rowing_task_left.tscn"),
	Task_type.LEAK: load("res://Scenes/leak.tscn"),
	Task_type.PUDDLE: load("res://Scenes/puddle.tscn"),
}

var cargo_scene := load("res://Scenes/cargo.tscn")

var action_color := Color(1, 0.741, 0.196)
var crew_select_color := Color(0, 0.843, 0.196)
var disabled_modulate := Color(1, 1, 1, 0.498)
var modulate_reset := Color(1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_task(type: Task_type) -> Task:
	if type != Task_type.NONE:
		return task_dict[type].duplicate().instantiate()
	else:
		return null

func generate_cargo() -> Cargo:
	return cargo_scene.duplicate().instantiate()


func set_boat(new_boat: Boat):
	boat = new_boat
	boat_ready.emit(boat)

func set_level(new_level: Level):
	level = new_level
	level.completed.connect(_on_level_completed)
	level_ready.emit()

func update_boat_speed(speed: int):
	boat_speed = speed
	speed_updated.emit(speed)
	
func update_cargo_condition(condition: int, max_condition: int):
	cargo_info["max_condition"] = max_condition
	cargo_info["condition"] = condition
	cargo_condition_updated.emit(cargo_info["max_condition"], cargo_info["condition"])
	
func update_cargo_items(num_items: int, item_health: int, item_texture: CompressedTexture2D):
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
