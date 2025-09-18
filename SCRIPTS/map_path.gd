extends Line2D

class_name MapPath

@export var connected_button : Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_revealed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_instance_valid(connected_button):
		modulate = Color.TRANSPARENT
		connected_button.mouse_entered.connect(set_highlight.bind(true))
		connected_button.mouse_exited.connect(set_highlight.bind(false))

func _process(delta: float) -> void:
	visible = not connected_button.disabled

func set_highlight(is_enable: bool):
	if connected_button is LevelButton:
		if not connected_button.stage_data.unlocked:
			return
	material.set_shader_parameter("on", is_enable)

func reveal_self():
	is_revealed = true
	animation_player.play("reveal")

func _on_visibility_changed() -> void:
	if visible and not is_revealed:
		reveal_self()
