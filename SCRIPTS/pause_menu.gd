extends Control

signal button_pressed

@onready var resume_button: Button = $MenuContent/MenuButtons/ResumeButton
@export var focus_button: Button

func _on_resume_button_pressed() -> void:
	button_pressed.emit("Play")

func _on_restart_button_pressed() -> void:
	button_pressed.emit("Restart")

func _on_controls_button_pressed() -> void:
	button_pressed.emit("Controls")

func _on_main_menu_button_pressed() -> void:
	button_pressed.emit("Main menu")

func _on_level_select_button_pressed() -> void:
	button_pressed.emit("Level")
	
func _on_resume_button_visibility_changed() -> void:
	if Globals.joypad_connected and visible:
		if is_instance_valid(resume_button):
			resume_button.grab_focus()
		elif is_instance_valid(focus_button):
			focus_button.grab_focus()

func _on_settings_button_pressed() -> void:
	button_pressed.emit("Settings")
