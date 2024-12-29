extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.speed_updated.connect(_boat_speed_updated)
	_boat_speed_updated()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _boat_speed_updated():
	$CanvasLayer/HBoxContainer/Label3.text = str(Globals.boat_speed)

func _on_boat_ready() -> void:
	Globals.set_boat($Boat)


func _on_leak_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("leak").size() < 3:
		Globals.boat.spawn_leak()
