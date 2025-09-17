extends Button

class_name LevelButton

signal selected

@export var stage_data : StageData

@onready var stats_panel_position: Marker2D = $StatsPanelPosition
@onready var stats_panel: LevelStatsPanel = $StatsPanelPosition/LevelStatsPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disabled = not stage_data.unlocked
	
	stats_panel.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visibility_changed() -> void:
	disabled = not stage_data.unlocked
	button_pressed = false
	if is_instance_valid(stats_panel):
		stats_panel.load_level_stats(stage_data.level_stats)

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# If space, place stats panel to left or right of button, whichever is closer to the middle of screen
		var viewport_rect = get_viewport_rect()
		var mouse_pos = get_global_mouse_position()
		if mouse_pos.x > viewport_rect.get_center().x:
			stats_panel_position.global_position = mouse_pos + Vector2(-20 - stats_panel.size.x, 0)
		else:
			stats_panel_position.global_position = mouse_pos + Vector2(20, 0)
		
		if mouse_pos.y > viewport_rect.get_center().y:
			stats_panel_position.global_position.y = mouse_pos.y - stats_panel.size.y
		
		stats_panel.show()
	else:
		stats_panel.hide()

func _on_level_stats_panel_button_pressed(button_type: CustomMenuButton.Type) -> void:
	match button_type:
		CustomMenuButton.Type.PLAY:
			selected.emit()
