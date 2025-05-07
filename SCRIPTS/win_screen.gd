extends Control

class_name WinScreen

signal button_pressed

@onready var next_level_button: Button = $MenuContent/MenuButtons/NextLevelButton
@onready var time_value: Label = $MenuContent/LevelStats/TimeStats/Value
@onready var percentage_label: Label = $MenuContent/LevelStats/TimeStats/PercentageLabel
@onready var cargo_value: Label = $MenuContent/LevelStats/CargoStats/Value
@onready var success_value: Label = $MenuContent/LevelStats/SuccessStats/Value
@onready var puddle_value: Label = $MenuContent/LevelStats/PuddleStats/Value
@onready var leak_value: Label = $MenuContent/LevelStats/LeakStats/Value
@onready var rat_value: Label = $MenuContent/LevelStats/RatStats/Value

var level_stats: LevelStats

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_finish_stats(new_level_stats: LevelStats):
	level_stats = new_level_stats
	update_finish_stats()

func update_finish_stats():
	time_value.text = StopWatch.time_string_from_seconds(level_stats.finish_seconds)
	if level_stats.calculate_speed_percentage() < 1:
		percentage_label.text = "(Avg. Speed " + str(level_stats.calculate_speed_percentage() * 100).substr(0,4) + "%)"
	else:
		percentage_label.text = "(Avg. Speed " + str(level_stats.calculate_speed_percentage() * 100).substr(0,3) + "%)"
	cargo_value.text = str(level_stats.calculate_cargo_percentage()* 100).substr(0,4) + "%"
	success_value.text = str(level_stats.calculate_success_percentage() * 100).substr(0,4) + "%"
	puddle_value.text = str(level_stats.puddles_fixed) + "/" + str(level_stats.puddles_spawned)
	leak_value.text = str(level_stats.leaks_fixed) + "/" + str(level_stats.leaks_spawned)
	rat_value.text = str(level_stats.rats_fixed) + "/" + str(level_stats.rats_spawned)

func _on_next_level_button_pressed():
	button_pressed.emit("Next")

func _on_restart_button_pressed():
	button_pressed.emit("Restart")

func _on_main_menu_button_pressed():
	button_pressed.emit("Main menu")

func _on_next_level_button_visibility_changed() -> void:
	if Globals.joypad_connected and visible:
		next_level_button.grab_focus()
