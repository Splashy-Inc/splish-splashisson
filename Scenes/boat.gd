extends Node2D

class_name Boat

# Number of deck segments
@export var deck_length: int
@export var deck_scene: PackedScene

# Tasks that should be filled into the deck segments
@export var deck_tasks: Array[Globals.Task_type]

var speed = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_boat()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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

func change_speed(change: int):
	speed += change
	if speed < 0:
		speed = 0
	Globals.update_boat_speed(speed)
