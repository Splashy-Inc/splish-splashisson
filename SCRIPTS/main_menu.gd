extends Control

signal button_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_button_pressed():
	button_pressed.emit("Play")

func _on_controls_button_pressed():
	button_pressed.emit("Controls")

func _on_quit_button_pressed():
	button_pressed.emit("Quit")

func _on_level_select_button_pressed():
	button_pressed.emit("Level")
