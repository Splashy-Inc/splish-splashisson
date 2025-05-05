extends Node2D

class_name Dock

@export var boat: Boat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not boat:
		boat = Globals.boat
		Globals.boat_ready.connect(_on_boat_ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if boat:
		global_position.y += boat.speed * delta
		if global_position.y > 0 and boat.global_position.distance_to(global_position) > boat.length:
			queue_free()

func _on_boat_ready(new_boat: Boat):
	boat = new_boat
