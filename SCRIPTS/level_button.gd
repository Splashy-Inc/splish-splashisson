extends Button

class_name LevelButton

@export var stage_data : StageData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disabled = not stage_data.unlocked

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visibility_changed() -> void:
	disabled = not stage_data.unlocked
