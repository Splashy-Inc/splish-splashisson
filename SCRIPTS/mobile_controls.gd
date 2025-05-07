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
		if player.selection_target:
			select_button.modulate = Globals.modulate_reset
		else:
			select_button.modulate = Globals.disabled_modulate
		if player.action_target:
			act_button.modulate = Globals.modulate_reset
		else:
			act_button.modulate = Globals.disabled_modulate
