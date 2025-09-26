extends Button

class_name LevelButton

signal selected

@export var stage_data : StageData

@onready var stats_panel: LevelStatsPanel = $LevelStatsPanel
@onready var hover_sound: AudioStreamPlayer = $HoverSound
@onready var click_sound: AudioStreamPlayer = $ClickSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disabled = not stage_data.unlocked
	
	stats_panel.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visibility_changed() -> void:
	if visible:
		disabled = not stage_data.unlocked
		button_pressed = false
		if is_instance_valid(stats_panel):
			stats_panel.load_level_stats(stage_data.level_stats)
		if not disabled:
			focus_mode = FOCUS_ALL
			if stage_data.level_stats.finish_seconds > 0:
				theme_type_variation = "LevelButton"
		else:
			focus_mode = FOCUS_NONE

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		var viewport_rect = get_viewport_rect()
		if Globals.joypad_connected:
			stats_panel.global_position = viewport_rect.get_center() - stats_panel.size/2
		else:
			# If space, place stats panel to left or right of button, whichever is closer to the middle of screen
			var mouse_pos = get_global_mouse_position()
			if mouse_pos.x > viewport_rect.get_center().x:
				stats_panel.global_position = mouse_pos + Vector2(-20 - stats_panel.size.x, 0)
			else:
				stats_panel.global_position = mouse_pos + Vector2(20, 0)
			
			if mouse_pos.y > viewport_rect.get_center().y:
				stats_panel.global_position.y = mouse_pos.y - stats_panel.size.y
			
		stats_panel.show()
		click_sound.play()
	else:
		stats_panel.hide()

func _on_level_stats_panel_button_pressed(button_type: CustomMenuButton.Type) -> void:
	match button_type:
		CustomMenuButton.Type.PLAY:
			selected.emit()

func _on_mouse_entered() -> void:
	if not disabled and not button_pressed:
		hover_sound.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and button_pressed:
		button_pressed = false
		grab_focus()
