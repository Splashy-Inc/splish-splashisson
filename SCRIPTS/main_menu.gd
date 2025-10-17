extends Control

signal button_pressed

@onready var story_button: Button = $MenuContent/MenuButtons/StoryModeButton
@onready var quit_button: Button = $MenuContent/MenuButtons/QuitButton

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Globals.is_node_ready():
		await Globals.ready
	if Globals.is_mobile or OS.has_feature("web"):
		quit_button.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_story_button_pressed():
	button_pressed.emit("Play")

func _on_controls_button_pressed():
	button_pressed.emit("Controls")

func _on_quit_button_pressed():
	button_pressed.emit("Quit")

func _on_level_select_button_pressed():
	button_pressed.emit("Level")

func _on_story_button_visibility_changed() -> void:
	if visible:
		if not is_node_ready():
			await ready
		story_button.grab_focus()

func _on_settings_button_pressed() -> void:
	button_pressed.emit("Settings")
