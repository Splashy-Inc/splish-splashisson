extends Resource

class_name LevelStats

var length_seconds : float
var finish_seconds : float
var speed_percentage : float
var cargo_max_condition : float
var cargo_finish_condition : float
var cargo_condition_percentage : float
var success_percentage : float
var puddles_spawned : int
var puddles_fixed : int
var leaks_spawned : int
var leaks_fixed : int
var rats_spawned : int
var rats_fixed : int

var speed_success_modifier = .75
const SPEED_SUCCESS_WEIGHT = 1.0
const CARGO_SUCCESS_WEIGHT = 1.0
const WEIGHT_TOTAL = SPEED_SUCCESS_WEIGHT + CARGO_SUCCESS_WEIGHT

func calculate_speed_percentage():
	speed_percentage = finish_seconds / (length_seconds * speed_success_modifier)
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
