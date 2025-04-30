extends Control

signal button_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_main_menu_button_pressed():
	button_pressed.emit("Main menu")

func _on_restart_button_pressed():
	button_pressed.emit("Restart")

func _on_quit_button_pressed():
	button_pressed.emit("Quit")
