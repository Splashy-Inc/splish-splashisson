extends Node2D

class_name Boat

signal stopped
signal set_up

# Number of deck segments
@export var deck_length: int
@export var deck_scene: PackedScene
@onready var bow_slot: Node2D = $NavigationRegion2D/BowSlot
@onready var deck_slot: Node2D = $NavigationRegion2D/DeckSlot
@onready var stern_slot: Node2D = $NavigationRegion2D/SternSlot

# Tasks that should be filled into the deck segments
@export var deck_tasks: Array[Globals.Task_type]

var speed = 0
var total_speed = 0
var max_speed = 0
var is_stopped = false
var length: int
var end_dock: Dock

var setup_checklist = {
	"bow": 1,
	"deck": deck_length,
	"stern": 1,
}

var playable_cells: Array[Vector2i]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_boat()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var new_speed = 0
	if is_stopped and speed >= 0:
		if speed > 1:
			new_speed = clamp(abs(global_position.y - end_dock.global_position.y), 1, speed)
		else:
			new_speed = 0
			end_dock.global_position.y = global_position.y
		if new_speed != speed:
			speed = int(new_speed)
			Globals.update_boat_speed(speed)

func _generate_boat():
	# Clear current deck segments
	for segment in deck_slot.get_children():
		if segment is Deck:
			segment.clear_deck()
		segment.free()
	
	# Generate each deck segment
	# TODO: Update to generate with more than 1 deck segment
	var deck_tasks_to_place = deck_tasks
	deck_length = 1
	setup_checklist["deck"] = deck_length
	for i in deck_length:
		var new_deck_segment = deck_scene.instantiate()
		if new_deck_segment is Deck:
			new_deck_segment.tasks_set_up.connect(_on_deck_segment_tasks_set_up)
			var tasks = deck_tasks_to_place.slice(0, 4)
			deck_tasks_to_place = deck_tasks_to_place.slice(4)
			new_deck_segment.initialize(tasks)
			deck_slot.add_child(new_deck_segment)
	
	length = bow_slot.global_position.distance_to(stern_slot.global_position) + get_viewport_rect().size.y
	
	change_speed(0)
	
func set_deck_length(new_length: int):
	deck_length = new_length
	setup_checklist["deck"] = deck_length
	_generate_boat()

func change_speed(change: int):
	if not is_stopped:
		total_speed += change
		speed = clamp(total_speed, 0, max_speed)
		Globals.update_boat_speed(speed)

func spawn_leak():
	var spawn_point = $PlayGrid.global_position + Vector2(randi_range(0,300), randi_range(0,length))
	while not is_point_in_boat(spawn_point):
		spawn_point = $PlayGrid.global_position + Vector2(randi_range(0,300), randi_range(0,length))
	if not $PlayGrid.spawn_leak(spawn_point):
		spawn_leak()

func spawn_puddle(spawn_point: Vector2):
	if is_point_in_boat(spawn_point):
		return $PlayGrid.spawn_puddle(spawn_point)
	return null
	
func add_obstacle(new_obstacle: Node2D):
	if new_obstacle is Puddle:
		$NavigationRegion2D/Obstacles/Puddles.add_child(new_obstacle)
	elif new_obstacle is Leak:
		$NavigationRegion2D/Obstacles/Leaks.add_child(new_obstacle)
	else:
		$NavigationRegion2D/Obstacles.add_child(new_obstacle)
		
func is_point_in_boat(point: Vector2):
	var bow = bow_slot.get_children().front()
	var stern = stern_slot.get_children().front()
	var decks = deck_slot.get_children()
	
	if bow.is_point_in_play_space(point) or stern.is_point_in_play_space(point):
		return true
	
	for deck in decks:
		if deck.is_point_in_play_space(point):
			return true
	
	return false

func get_max_speed():
	var rowing_tasks = []
	for deck in deck_slot.get_children():
		rowing_tasks.append_array(deck.get_rowing_tasks())
	if not rowing_tasks.is_empty():
		max_speed = rowing_tasks.front().SPEED_CHANGE * rowing_tasks.size()
	return max_speed

func stop(dock: Dock):
	end_dock = dock
	is_stopped = true
	stopped.emit()
	
func _on_deck_segment_tasks_set_up():
	setup_checklist["deck"] -= 1
	if setup_checklist["deck"] <= 0:
		_check_set_up()

func _on_bow_cargo_set_up() -> void:
	setup_checklist["bow"] -= 1
	if setup_checklist["bow"] <= 0:
		_check_set_up()

func _on_stern_cargo_set_up() -> void:
	setup_checklist["stern"] -= 1
	if setup_checklist["stern"] <= 0:
		_check_set_up()

func _check_set_up():
	if setup_checklist["bow"] <= 0 and setup_checklist["stern"] <= 0 and setup_checklist["deck"] <= 0:
		get_max_speed()
		$PlayGrid.global_position = bow_slot.get_children().front().get_play_grid_origin()
		$NavigationRegion2D.bake_navigation_polygon()
		set_up.emit()
