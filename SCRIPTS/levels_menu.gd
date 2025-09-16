extends Control

signal stage_selected(stage_data: StageData)

@onready var map: AnimatedSprite2D = $Map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in map.get_children():
		if child is LevelButton:
			child.pressed.connect(_on_stage_pressed.bind(child))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_stage_pressed(button: LevelButton):
	stage_selected.emit("Play", button.stage_data)
