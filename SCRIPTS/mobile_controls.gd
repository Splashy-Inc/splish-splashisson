extends Control

class_name MobileControls

@onready var act_button: TouchScreenButton = $ActButton
@onready var select_button: TouchScreenButton = $SelectButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	select_button.material.set_shader_parameter("line_color", Globals.crew_select_color)
	act_button.material.set_shader_parameter("line_color", Globals.action_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player: Player
	for new_player in get_tree().get_nodes_in_group("player"):
		if new_player is Player:
			player = new_player
			break
	if player:
		select_button.material.set_shader_parameter("on", player.selection_target and not select_button.is_pressed())
		act_button.material.set_shader_parameter("on", player.action_target and not act_button.is_pressed())
