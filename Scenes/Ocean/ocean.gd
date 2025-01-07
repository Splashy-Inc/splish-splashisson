extends Parallax2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.speed_updated.connect(_on_speed_updated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_speed_updated(speed: int):
	# Offset the ocean based on the position before updating the autoscroll (WORKAROUND)
	# There is a known "issue" with the parallax resetting when autoscroll is updated,
	#   which has a solution in 4.4, which does not have a stable release as of writing:
	#   https://github.com/godotengine/godot/issues/97605
	var cur_position = position
	set_autoscroll(Vector2(0, clamp(speed/5, 0, 400)))
	scroll_offset.y = cur_position.y
