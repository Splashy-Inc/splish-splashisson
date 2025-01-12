extends Node2D

class_name Boat

signal stopped

# Number of deck segments
@export var deck_length: int
@export var deck_scene: PackedScene

# Tasks that should be filled into the deck segments
@export var deck_tasks: Array[Globals.Task_type]

var speed = 0
var max_speed = 0
var drag = 10
var is_stopped = false
var length: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_boat()
	get_max_speed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_stopped and speed >= 0:
		speed = clamp(speed - ceil(drag * delta), 0, max_speed/3)
		Globals.update_boat_speed(speed)

func _generate_boat():
	# Clear current deck segments
	for segment in $DeckSlot.get_children():
		if segment is Deck:
			segment.clear_deck()
		segment.free()
	
	# Generate each deck segment
	# TODO: Update to generate with more than 1 deck segment
	var deck_tasks_to_place = deck_tasks
	for i in deck_length:
		var new_deck_segment = deck_scene.instantiate()
		var tasks = deck_tasks_to_place.slice(0, 4)
		deck_tasks_to_place = deck_tasks_to_place.slice(4)
		new_deck_segment.initialize(tasks)
		$DeckSlot.add_child(new_deck_segment)
	
	length = $BowSlot.global_position.distance_to($SternSlot.global_position) + get_viewport_rect().size.y
	
	change_speed(0)

func change_speed(change: int):
	if not is_stopped:
		speed += change
		Globals.update_boat_speed(speed)

func spawn_leak():
	$DeckSlot.get_children().front().spawn_leak()

func spawn_puddle(spawn_point: Vector2):
	if is_point_in_boat(spawn_point):
		return $DeckSlot.get_children().front().spawn_puddle(spawn_point)
	
	return null
	
func add_obstacle(new_obstacle: Node2D):
	if new_obstacle is Puddle:
		$Obstacles/Puddles.add_child(new_obstacle)
	elif new_obstacle is Leak:
		$Obstacles/Leaks.add_child(new_obstacle)
	else:
		$Obstacles.add_child(new_obstacle)
		
func is_point_in_boat(point: Vector2):
	var bow = $BowSlot/Bow
	var stern = $SternSlot/Stern
	var decks = $DeckSlot.get_children()
	
	if bow.is_point_in_play_space(point) or stern.is_point_in_play_space(point):
		return true
	
	for deck in decks:
		if deck.is_point_in_play_space(point):
			return true
	
	return false

func get_max_speed():
	var rowing_tasks = []
	for deck in $DeckSlot.get_children():
		rowing_tasks.append_array(deck.get_rowing_tasks())
	max_speed = rowing_tasks.front().SPEED_CHANGE * rowing_tasks.size()
	return max_speed

func stop():
	is_stopped = true
	stopped.emit()
