extends Node

class_name Cutscene

signal start_pressed

@export var boat_length := 1
@export var level_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Boat.set_deck_length(boat_length)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventKey:
		_on_continue_pressed()

func _on_continue_pressed() -> void:
	start_pressed.emit()
