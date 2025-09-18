extends Line2D

class_name MapPath

@export var connected_button : Button

var is_selected := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_instance_valid(connected_button):
		connected_button.mouse_entered.connect(set_highlight.bind(true))
		connected_button.mouse_exited.connect(set_highlight.bind(false))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = not connected_button.disabled

func set_highlight(is_enable: bool):
	if connected_button is LevelButton:
		if not connected_button.stage_data.unlocked:
			return
	material.set_shader_parameter("on", is_enable)
