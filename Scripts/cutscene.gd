extends Node

class_name Cutscene

signal start_pressed

@export var boat_length := 0
@export var level_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Not sure if there is a better way to do this, but it seems to work for now
	if boat_length == 0:
		var temp_level := level_scene.instantiate()
		if temp_level is Level:
			boat_length = temp_level.boat_length
			temp_level.queue_free()
	$Boat.set_deck_length(boat_length)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_continue_pressed() -> void:
	start_pressed.emit(level_scene)
