extends Node2D

class_name Boat

signal stopped
signal set_up

# Number of deck segments
@export var deck_length: int
@export var deck_scene: PackedScene
var deck_segments_setup_left = deck_length

# Tasks that should be filled into the deck segments
@export var deck_tasks: Array[Globals.Task_type]

var speed = 0
var total_speed = 0
var max_speed = 0
var is_stopped = false
var length: int
var end_dock: Dock

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
	for segment in $DeckSlot.get_children():
		if segment is Deck:
			segment.clear_deck()
		segment.free()
	
	# Generate each deck segment
	# TODO: Update to generate with more than 1 deck segment
	var deck_tasks_to_place = deck_tasks
	deck_length = 1
	deck_segments_setup_left = deck_length
	for i in deck_length:
		var new_deck_segment = deck_scene.instantiate()
		if new_deck_segment is Deck:
			new_deck_segment.tasks_set_up.connect(_on_deck_segment_tasks_set_up)
			var tasks = deck_tasks_to_place.slice(0, 4)
			deck_tasks_to_place = deck_tasks_to_place.slice(4)
			new_deck_segment.initialize(tasks)
			$DeckSlot.add_child(new_deck_segment)
	
	length = $BowSlot.global_position.distance_to($SternSlot.global_position) + get_viewport_rect().size.y
	
	change_speed(0)
	
func set_deck_length(new_length: int):
	deck_length = new_length
	_generate_boat()

func change_speed(change: int):
	if not is_stopped:
		total_speed += change
		speed = clamp(total_speed, 0, max_speed)
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
	if not rowing_tasks.is_empty():
		max_speed = rowing_tasks.front().SPEED_CHANGE * rowing_tasks.size()
	return max_speed

func stop(dock: Dock):
	end_dock = dock
	is_stopped = true
	stopped.emit()
	
func _on_deck_segment_tasks_set_up():
	deck_segments_setup_left -= 1
	if deck_segments_setup_left <= 0:
		get_max_speed()
		set_up.emit()
