extends Control

class_name WinScreen

signal button_pressed

@export var level_stats_panel: LevelStatsPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_finish_stats(new_level_stats: LevelStats):
	level_stats_panel.load_level_stats(new_level_stats)
	level_stats_panel.title_label.text = "You win!"

func _on_button_pressed(button_type: CustomMenuButton.Type):
	match button_type:
		CustomMenuButton.Type.NEXT:
			button_pressed.emit("Next")
		CustomMenuButton.Type.RESTART:
			button_pressed.emit("Restart")
		CustomMenuButton.Type.MAIN_MENU:
			button_pressed.emit("Main menu")
