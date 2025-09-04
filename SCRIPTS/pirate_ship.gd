extends Node2D

class_name PirateShip

signal died

@export var target_boat : Boat
@export var base_speed := 100
var speed := base_speed
var is_stopped := false
var is_leaving := false

const STARTING_X = -8

@onready var pirates: Node2D = $Pirates
@onready var boarding_timer: Timer = $BoardingTimer

var pirate_list : Array[Pirate]
var boarding_list : Array[Pirate]

func _ready() -> void:
	if is_instance_valid(target_boat):
		target_boat.set_up.connect(_on_target_boat_set_up)

func _physics_process(delta: float) -> void:
	if is_instance_valid(target_boat):
		if is_leaving:
			var new_speed := speed
			if speed < base_speed:
				new_speed = clamp(abs(global_position.y - target_boat.global_position.y) + 5, 1, base_speed)
			else:
				new_speed = base_speed
			if new_speed != speed:
				speed = int(new_speed)
					
			global_position.y += speed * delta
			if global_position.y > target_boat.length * 2:
				_die()
		else:
			if not is_stopped and abs(global_position.y - target_boat.global_position.y) < maxf(speed, target_boat.length/4):
				is_stopped = true
				start_boarding()
			
			if is_stopped and speed > 0:
				var new_speed := speed
				if speed > 1:
					new_speed = clamp(abs(global_position.y - target_boat.global_position.y), 1, speed)
				else:
					new_speed = 0
					global_position.y = target_boat.global_position.y
				if new_speed != speed:
					speed = int(new_speed)
			
			global_position.y += speed * delta

func initialize(boat: Boat):
	if boat:
		target_boat = boat
	
	global_position = Vector2(STARTING_X, -(boat.length + get_viewport_rect().size.y))

func start_boarding():
	for child in pirates.get_children():
		if child is Pirate:
			child.died.connect(_on_pirate_died.bind(child))
			boarding_list.append(child)
			pirate_list.append(child)
	boarding_timer.start()

func _on_target_boat_set_up():
	initialize(target_boat)

func _on_pirate_died(pirate: Pirate):
	pirate_list.erase(pirate)
	if pirate_list.is_empty():
		is_leaving = true

func _die():
	died.emit()
	queue_free()

func _on_boarding_timer_timeout() -> void:
	if not boarding_list.is_empty():
		boarding_list.pop_front().board_boat(target_boat, (boarding_list.size() % 2 == 0))
