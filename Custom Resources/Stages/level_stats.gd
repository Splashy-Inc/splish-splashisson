extends Resource

class_name LevelStats

@export var level_data : StageData
@export var length_seconds : float
@export var finish_seconds : float
@export var speed_percentage : float
@export var cargo_max_condition : float
@export var cargo_finish_condition : float
@export var cargo_condition_percentage : float
@export var success_percentage : float
@export var puddles_spawned : int
@export var puddles_fixed : int
@export var leaks_spawned : int
@export var leaks_fixed : int
@export var rats_spawned : int
@export var rats_fixed : int
@export var seagulls_spawned : int
@export var seagulls_fixed : int

@export var speed_success_modifier = .75
const SPEED_SUCCESS_WEIGHT = 1.0
const CARGO_SUCCESS_WEIGHT = 1.0
const WEIGHT_TOTAL = SPEED_SUCCESS_WEIGHT + CARGO_SUCCESS_WEIGHT

func calculate_speed_percentage():
	speed_percentage = (length_seconds / speed_success_modifier) / finish_seconds
	return speed_percentage
	
func calculate_cargo_percentage():
	cargo_condition_percentage = cargo_finish_condition / cargo_max_condition
	return cargo_condition_percentage

func calculate_success_percentage():
	calculate_speed_percentage()
	calculate_cargo_percentage()
	var speed_percent_weighted = speed_percentage * SPEED_SUCCESS_WEIGHT / WEIGHT_TOTAL
	var cargo_percent_weighted = cargo_condition_percentage * CARGO_SUCCESS_WEIGHT / WEIGHT_TOTAL
	success_percentage = speed_percent_weighted + cargo_percent_weighted
	return success_percentage
