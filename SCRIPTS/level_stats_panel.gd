extends PanelContainer

class_name LevelStatsPanel

signal play_pressed
signal button_pressed(button_type: CustomMenuButton.Type)

@export var title : String
@export var level_stats : LevelStats
@export var button_scenes : Array[PackedScene]

@export var menu_buttons: VBoxContainer

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
	for child in menu_buttons.get_children():
		child.queue_free()
		
	for scene in button_scenes:
		var new_button = scene.instantiate()
		if new_button is CustomMenuButton:
			menu_buttons.add_child(new_button)
			new_button.pressed.connect(_on_button_pressed.bind(new_button.type))
	
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

func _on_button_pressed(button_type: CustomMenuButton.Type):
	button_pressed.emit(button_type)

func _on_visibility_changed() -> void:
	if Globals.joypad_connected and visible:
		menu_buttons.get_children().front().grab_focus()
