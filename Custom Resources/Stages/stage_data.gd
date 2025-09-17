extends Resource

class_name StageData

@export var unlocked := false

@export var cutscene_data : CutsceneData

@export var is_tutorial := false
@export var length_seconds := 60
@export var boat_length := 1
@export var boat_task_list : Array[Globals.Task_type]
@export var cargo_list: Array[CargoItemData]
@export var weather := Weather.Type.NONE
@export var num_rat_holes := 1
@export var rat_interval_seconds := 10
@export var seagull_interval_seconds := 10
@export var num_pirate_ships := 0
@export var start_pirates := 1

@export var level_stats := LevelStats.new()
