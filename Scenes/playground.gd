extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.boat = $Boat
	Globals.speed_updated.connect(_boat_speed_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _boat_speed_updated():
	$CanvasLayer/HBoxContainer/Label3.text = str(Globals.boat_speed)
