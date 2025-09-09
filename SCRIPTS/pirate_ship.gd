extends Node2D

class_name PirateShip

signal died

@export var target_boat : Boat
@export var base_speed := 100
var speed := base_speed
var is_stopped := false
var is_leaving := false

@export var pirate_scene : PackedScene
@export var num_pirates := 1

const STARTING_X = -8

@onready var pirate_slots: Node2D = $PirateSlots
@onready var boarding_timer: Timer = $BoardingTimer

var pirate_list : Array[Pirate]
var boarding_list : Array[Pirate]

func _ready() -> void:
	generate_pirates()
	
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

func initialize(boat: Boat, new_num_pirates: int = 1):
	if boat:
		target_boat = boat
	
	num_pirates = new_num_pirates
	generate_pirates()
	
	global_position = Vector2(STARTING_X, -(boat.length + get_viewport_rect().size.y))

func start_boarding():
	for pirate in get_pirates():
		if pirate is Pirate:
			boarding_list.append(pirate)
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

func generate_pirates():
	for pirate in pirate_list:
		pirate_list.erase(pirate)
		pirate.get_parent().remove_child(pirate)
		pirate.queue_free()
	
	var pirates_to_spawn = num_pirates
	for slot in pirate_slots.get_children():
		if slot.get_children().is_empty() and num_pirates > 0:
			slot.add_child(spawn_pirate())
			num_pirates -= 1

func spawn_pirate():
	var new_pirate := pirate_scene.instantiate() as Pirate
	new_pirate.died.connect(_on_pirate_died.bind(new_pirate))
	pirate_list.append(new_pirate)
	new_pirate.set_type(randi_range(Pirate.Type.NONE, Pirate.Type.HAMMER))
	return new_pirate

func get_pirates() -> Array[Pirate]:
	for pirate in pirate_list:
		if not is_instance_valid(pirate):
			pirate_list.erase(pirate)
	return pirate_list
