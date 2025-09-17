extends Resource

class_name LevelStats

@export var level_name : String
@export var length_seconds : float
@export var finish_seconds : float
var speed_percentage : float
@export var cargo_max_condition : float
@export var cargo_finish_condition : float
var cargo_condition_percentage : float
var success_percentage : float
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
	if length_seconds > 0:
		speed_percentage = (length_seconds / speed_success_modifier) / finish_seconds
	else: speed_percentage = 0.0
	return speed_percentage
	
func calculate_cargo_percentage():
	if cargo_max_condition > 0:
		cargo_condition_percentage = cargo_finish_condition / cargo_max_condition
	else:
		cargo_condition_percentage = 0.0
	return cargo_condition_percentage

func calculate_success_percentage():
	calculate_speed_percentage()
	calculate_cargo_percentage()
	var speed_percent_weighted = speed_percentage * SPEED_SUCCESS_WEIGHT / WEIGHT_TOTAL
	var cargo_percent_weighted = cargo_condition_percentage * CARGO_SUCCESS_WEIGHT / WEIGHT_TOTAL
	success_percentage = speed_percent_weighted + cargo_percent_weighted
	return success_percentage

func overwrite(new_stats: LevelStats):
	level_name = new_stats.level_name
	length_seconds = new_stats.length_seconds
	finish_seconds = new_stats.finish_seconds
	speed_percentage = new_stats.speed_percentage
	cargo_max_condition = new_stats.cargo_max_condition
	cargo_finish_condition = new_stats.cargo_finish_condition
	cargo_condition_percentage = new_stats.cargo_condition_percentage
	success_percentage = new_stats.success_percentage
	puddles_spawned = new_stats.puddles_spawned
	puddles_fixed = new_stats.puddles_fixed
	leaks_spawned = new_stats.leaks_spawned
	leaks_fixed = new_stats.leaks_fixed
	rats_spawned = new_stats.rats_spawned
	rats_fixed = new_stats.rats_fixed
	seagulls_spawned = new_stats.seagulls_spawned
	seagulls_fixed = new_stats.seagulls_fixed

	speed_success_modifier = .75
