extends Control

signal button_pressed

@onready var next_level_button: Button = $MenuContent/MenuButtons/NextLevelButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_next_level_button_pressed():
	button_pressed.emit("Next")

func _on_restart_button_pressed():
	button_pressed.emit("Restart")

func _on_main_menu_button_pressed():
	button_pressed.emit("Main menu")

func _on_next_level_button_visibility_changed() -> void:
	if Globals.joypad_connected and visible:
		next_level_button.grab_focus()
