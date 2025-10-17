extends Control

signal stage_selected(stage_data: StageData)
signal exited

@export var map: AnimatedSprite2D
@onready var level_select_sound: AudioStreamPlayer = $LevelSelect
@export var tutorial_button: LevelButton
@export var tutorial_button_animation_player: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveEvents.load_completed.connect(_on_load_game_data_completed)
	for child in map.get_children():
		if child is LevelButton:
			child.selected.connect(_on_stage_selected.bind(child))
			child.toggled.connect(_on_stage_button_toggled.bind(child))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_stage_selected(button: LevelButton):
	level_select_sound.play()
	if level_select_sound.playing:
		await level_select_sound.finished
	stage_selected.emit("Play", button.stage_data)

func _on_stage_button_toggled(toggled_on: bool, button: LevelButton):
	if toggled_on:
		for child in map.get_children():
			if child is LevelButton:
				if child != button:
					child.button_pressed = false

func _on_visibility_changed() -> void:
	if visible:
		tutorial_button.grab_focus()
		for child in map.get_children():
			if child is LevelButton:
				if child != tutorial_button and child.stage_data.unlocked:
					tutorial_button_animation_player.play("RESET")
					return # Skip everything below if any stages unlocked (tutorial already done/skipped)
		tutorial_button_animation_player.play("pulse")
	else:
		tutorial_button_animation_player.play("RESET")

func _on_back_button_pressed() -> void:
	if visible:
		exited.emit()

func _on_load_game_data_completed(loaded_resource: SaveData, game_mode: Globals.Game_mode):
	for button in map.get_children():
		if button is LevelButton:
			for stage in loaded_resource.stages:
				if stage.level_stats.level_name == button.stage_data.level_stats.level_name:
					button.stage_data = stage
