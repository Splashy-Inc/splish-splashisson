extends Node

class_name Level

var progress = 0
@export var minimum_seconds: int
var length = 0
var max_boat_speed = 0
var boat_speed = 0
var boat: Boat
var finished = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_boat_speed = boat.get_max_speed()
	length = max_boat_speed * minimum_seconds
	Globals.speed_updated.connect(_boat_speed_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not finished:
		progress += boat_speed * delta
		if progress >= length:
			finished = true
			boat.stop()
			print("Win!")

func _on_boat_ready() -> void:
	boat = $Boat
	Globals.set_boat(boat)

func _boat_speed_updated(speed: int):
	boat_speed = clamp(speed, 0, max_boat_speed)

func _on_leak_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("leak").size() < 3:
		pass
		Globals.boat.spawn_leak()
