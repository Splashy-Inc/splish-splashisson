extends Control

signal stage_selected(stage_data: StageData)

@onready var map: AnimatedSprite2D = $Map
@onready var level_select_sound: AudioStreamPlayer = $LevelSelect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
