extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_boat_ready() -> void:
	Globals.set_boat($Boat)

func _on_leak_spawn_timer_timeout() -> void:
	if get_tree().get_nodes_in_group("leak").size() < 3:
		Globals.boat.spawn_leak()
