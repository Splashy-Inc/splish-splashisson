extends Node

class_name Level

signal completed

var dock_scene = load("res://Scenes/dock.tscn")

var progress = 0
@export var minimum_seconds: int
var length = 0
var max_boat_speed = 0
var boat_speed = 0
var boat: Boat
var finished = false

var end_dock: Dock

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_boat_speed = boat.get_max_speed()
	length = max_boat_speed * minimum_seconds
	Globals.speed_updated.connect(_boat_speed_updated)
	
	# Spawn the end dock
	var viewport_rect = get_viewport().get_visible_rect()
	var dock_spawn_point = Vector2(viewport_rect.size.x, boat.global_position.y - length - boat.max_speed)
	end_dock = spawn_dock(dock_spawn_point)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not finished:
		progress += boat_speed * delta
		if progress >= length:
			finished = true
			boat.stop(end_dock)
			print("Win!")
			completed.emit()
		Globals.update_level_progress_percent(clamp(progress/length, 0.0, 1.0))

func _on_boat_ready() -> void:
	boat = $Boat
	Globals.set_boat(boat)

func _boat_speed_updated(speed: int):
	boat_speed = clamp(speed, 0, max_boat_speed)

func spawn_dock(spawn_point: Vector2):
	var new_dock = dock_scene.instantiate()
	add_child(new_dock)
	new_dock.global_position = spawn_point
	return new_dock
