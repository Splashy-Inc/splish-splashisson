extends Parallax2D

var boat_stopped = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.speed_updated.connect(_on_speed_updated)
	Globals.boat_ready.connect(_on_boat_ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_speed_updated(speed: int):
	# Offset the ocean based on the position before updating the autoscroll (WORKAROUND)
	# There is a known "issue" with the parallax resetting when autoscroll is updated,
	#   which has a solution in 4.4, which does not have a stable release as of writing:
	#   https://github.com/godotengine/godot/issues/97605
	var cur_position = position
	if boat_stopped:
		# TODO: Understand workaround here where we divide speed by an additional factor of 3
		#	in order to prevent ocean scroll from jumping to a very fast speed at start of slowdown
		set_autoscroll(Vector2(0, clamp(speed/15, 0, 400)))
	else:
		set_autoscroll(Vector2(0, clamp(speed/5, 0, 400)))
	scroll_offset.y = cur_position.y

func _on_boat_ready(boat: Boat):
	boat.stopped.connect(_on_boat_stopped)

func _on_boat_stopped():
	boat_stopped = true
