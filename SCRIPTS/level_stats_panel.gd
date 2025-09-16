extends PanelContainer

class_name LevelStatsPanel

signal play_pressed

@export var title : String
@export var level_stats : LevelStats

@onready var title_label : Label = $MenuContent/Title

@onready var time_value: Label = $MenuContent/LevelStats/TimeStats/Value
@onready var percentage_label: Label = $MenuContent/LevelStats/PercentageLabel
@onready var cargo_value: Label = $MenuContent/LevelStats/CargoStats/Value
@onready var success_value: Label = $MenuContent/LevelStats/SuccessStats/Value
@onready var puddle_value: Label = $MenuContent/LevelStats/PuddleStats/Value
@onready var leak_value: Label = $MenuContent/LevelStats/LeakStats/Value
@onready var rat_value: Label = $MenuContent/LevelStats/RatStats/Value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_level_stats(level_stats)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_level_stats(new_stats: LevelStats = level_stats):
	level_stats = new_stats
	title_label.text = level_stats.level_name
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

func _on_play_button_pressed() -> void:
	play_pressed.emit()
