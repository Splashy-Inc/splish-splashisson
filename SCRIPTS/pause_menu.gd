extends Control

signal button_pressed

@onready var resume_button: Button = $MenuContent/MenuButtons/ResumeButton

func _on_resume_button_pressed() -> void:
	button_pressed.emit("Play")

func _on_restart_button_pressed() -> void:
	button_pressed.emit("Restart")

func _on_controls_button_pressed() -> void:
	button_pressed.emit("Controls")

func _on_main_menu_button_pressed() -> void:
	button_pressed.emit("Main menu")

func _on_resume_button_visibility_changed() -> void:
	if Globals.joypad_connected and visible:
		resume_button.grab_focus()
