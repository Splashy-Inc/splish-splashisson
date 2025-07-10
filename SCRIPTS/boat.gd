extends Node2D

class_name Boat

signal stopped
signal set_up

# Number of deck segments
@export var deck_length: int
@export var deck_scene: PackedScene
@onready var bow_slot: Node2D = $NavigationRegion2D/BowSlot
@onready var bow: BoatEnd = $NavigationRegion2D/BowSlot/Bow
@onready var deck_slot: Node2D = $NavigationRegion2D/DeckSlot
@onready var stern_slot: Node2D = $NavigationRegion2D/SternSlot
@onready var stern: BoatEnd = $NavigationRegion2D/SternSlot/Stern
@onready var crew_container: Node = $Crew

# Tasks that should be filled into the deck segments
@export var deck_tasks: Array[Globals.Task_type]
@export var cargo_list: Array[Cargo.Cargo_type]
@export var generate_crew := true
var rowing_tasks: Array[RowingTask]

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
	initialize()

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

func initialize(new_deck_length: int = 1, ):
	set_deck_length(new_deck_length)
	_generate_boat()

func _generate_boat():
	# Clear current deck segments
	for segment in deck_slot.get_children():
		if segment is Deck:
			segment.clear_deck()
		segment.free()
	
	setup_checklist = {
		"bow": 1,
		"deck": deck_length,
		"stern": 1,
	}
	
	# Generate each deck segment and offset
	var deck_tasks_to_place = deck_tasks
	var y_offset := 0
	var deck_size_y := 0
	for i in deck_length:
		var new_deck_segment = deck_scene.instantiate() as Deck
		if new_deck_segment is Deck:
			deck_slot.add_child(new_deck_segment)
			if deck_length % 2 == 1: # Odd number of deck segments
				# Offset each segment by a whole deck segment, increasing every even segment
				# The first segment does not recieve any offset since it remains centered
				if i % 2 == 1:
					y_offset += new_deck_segment.get_size().y
			else: # Even number of deck segments
				# Offset each segment by a while segement, increasing every odd segment, 
				# The first 2 segments get a half segment offset
				if i % 2 == 0:
					if i < 1:
						y_offset += new_deck_segment.get_size().y/2
					else:
						y_offset += new_deck_segment.get_size().y
			
			# Alternate bow and stern, to keep things centered
			new_deck_segment.position.y = cos(i * PI) * y_offset * global_scale.y
			
			# With deck segments placed, then set up tasks
			new_deck_segment.tasks_set_up.connect(_on_deck_segment_tasks_set_up)
			var tasks = deck_tasks_to_place.slice(0, 4)
			deck_tasks_to_place = deck_tasks_to_place.slice(4)
			new_deck_segment.initialize(tasks)
			
			if deck_size_y == 0:
				deck_size_y = new_deck_segment.get_size().y
	
	# Offset boat ends
	y_offset += stern.get_size().y/2 + deck_size_y/2
	stern_slot.position.y = y_offset
	bow_slot.position.y = -y_offset
	
	# Set the cargo
	var temp_cargo_list := cargo_list.duplicate()
	if temp_cargo_list.is_empty():
		stern.set_cargo(Cargo.Cargo_type.NONE)
		bow.set_cargo(Cargo.Cargo_type.NONE)
	else:
		stern.set_cargo(temp_cargo_list.front())
		temp_cargo_list.pop_front()
		if temp_cargo_list.is_empty():
			bow.set_cargo(Cargo.Cargo_type.NONE)
		else:
			bow.set_cargo(temp_cargo_list.front())
	
	length = bow_slot.global_position.distance_to(stern_slot.global_position) + get_viewport_rect().size.y
	change_speed(0)

func set_deck_length(new_length: int):
	deck_length = new_length
	setup_checklist["deck"] = deck_length

func change_speed(change: int):
	if not is_stopped:
		total_speed += change
		speed = clamp(total_speed, 0, max_speed)
		Globals.update_boat_speed(speed)

func spawn_leak(spawn_point: Vector2 = Vector2.ZERO):
	if spawn_point == Vector2.ZERO:
		spawn_point = get_spawn_point()
	while not is_point_in_boat(spawn_point):
		spawn_point = get_spawn_point()
	var new_leak = $PlayGrid.spawn_leak(spawn_point)
	if not new_leak:
		return spawn_leak()
	else:
		return new_leak

func spawn_puddle(spawn_point: Vector2 = Vector2.ZERO):
	if spawn_point == Vector2.ZERO:
		spawn_point = get_spawn_point()
		while not is_point_in_boat(spawn_point):
			spawn_point = get_spawn_point()
	if is_point_in_boat(spawn_point):
		return $PlayGrid.spawn_puddle(spawn_point)
	return null

func spawn_rat_hole(spawn_point: Vector2 = Vector2.ZERO):
	if spawn_point == Vector2.ZERO:
		spawn_point = get_spawn_point()
	
	for cargo in get_tree().get_nodes_in_group("cargo"):
		while not (is_point_in_boat(spawn_point) and spawn_point.distance_to(cargo.global_position) < length and spawn_point.distance_to(cargo.global_position) > 256):
			spawn_point = get_spawn_point()
		
		print(spawn_point, " ", spawn_point.distance_to(cargo.global_position), " ", length)
	var new_rat_hole = $PlayGrid.spawn_rat_hole(spawn_point)
	if not new_rat_hole:
		return spawn_rat_hole()
	else:
		return new_rat_hole

func get_spawn_point():
	return $PlayGrid.global_position + Vector2(randi_range(0,220), randi_range(0,length))
	
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
		if generate_crew:
			_generate_crew()
		set_up.emit()

func _generate_crew():
	for crew in crew_container.get_children():
		if crew is Crew:
			crew.set_assignment(null)
		crew.queue_free()
	
	for deck_segment in deck_slot.get_children():
		if deck_segment is Deck:
			var rowing_tasks = deck_segment.get_rowing_tasks() as Array[RowingTask]
			for rowing_task in rowing_tasks:
				var new_crew = Globals.generate_crew() as Crew
				crew_container.add_child(new_crew)
				new_crew.global_position = rowing_task.dismount_point.global_position
				_set_crew_assignment(new_crew, rowing_task)

# Workaround to weird issue where having the automatic assignment happen too quickly
#	caused the rowing stop animation to not play properly
# Waiting for nodes to be ready didn't seem to work...
func _set_crew_assignment(crew: Crew, assignment: Task):
	await get_tree().create_timer(.5).timeout
	if is_instance_valid(crew):
		crew.set_assignment(assignment)
