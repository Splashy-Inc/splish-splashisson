extends Parallax2D

var boat_stopped = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.speed_updated.connect(_on_speed_updated)
	Globals.boat_ready.connect(_on_boat_ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_speed_updated(speed: float):
	# Offset the ocean based on the position before updating the autoscroll (WORKAROUND)
	# There is a known "issue" with the parallax resetting when autoscroll is updated,
	#   which has a solution in 4.4, which does not have a stable release as of writing:
	#   https://github.com/godotengine/godot/issues/97605
	var cur_position = position
	
	set_autoscroll(Vector2(0, speed))
	scroll_offset.y = cur_position.y

func _on_boat_ready(boat: Boat):
	boat.stopped.connect(_on_boat_stopped)

func _on_boat_stopped():
	boat_stopped = true
