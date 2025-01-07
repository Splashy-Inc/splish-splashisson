extends Node

signal speed_updated
signal boat_ready
signal cargo_condition_updated
signal cargo_items_updated

var boat_speed = 0

var cargo_info = {
	"max_condition": 0,
	"condition": 0,
	"max_items": 0,
	"item_health": 0,
	"item_texture": CompressedTexture2D.new().load("res://Art/Cargo/Ham/Ham1.png"),
}
var boat: Boat

enum Task_type {
	ROWING,
	LEAK,
	PUDDLE,
}

var task_dict = {
	Task_type.ROWING: load("res://Scenes/rowing_task.tscn"),
	Task_type.LEAK: load("res://Scenes/leak.tscn"),
	Task_type.PUDDLE: load("res://Scenes/puddle.tscn"),
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_task(type: Task_type) -> Task:
	return task_dict[type].duplicate().instantiate()

func set_boat(new_boat: Boat):
	boat = new_boat
	boat_ready.emit()

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
