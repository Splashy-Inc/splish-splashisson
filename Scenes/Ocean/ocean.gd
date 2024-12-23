extends Parallax2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.speed_updated.connect(_on_speed_updated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_speed_updated():
	autoscroll.y = clamp(Globals.boat_speed/5, 0, 400)
