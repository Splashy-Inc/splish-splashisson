extends Node

signal speed_updated
signal boat_ready

var boat_speed = 0
var boat: Boat

enum Task_type {
	ROWING,
}

var task_dict = {
	Task_type.ROWING: load("res://Scenes/rowing_task.tscn"),
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
	speed_updated.emit()
