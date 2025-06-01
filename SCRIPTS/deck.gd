extends StaticBody2D

class_name Deck

signal tasks_set_up

@export var tasks: Array[Globals.Task_type]
var spawn_boundary: Rect2
var task_slots : Array[TaskSlot]

@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_boundary = $SpawnArea/CollisionShape2D.shape.get_rect()
	call_deferred("_set_up_tasks")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize(tasks_to_place: Array[Globals.Task_type]):
	tasks = tasks_to_place
	
func _set_up_tasks():
	task_slots = $PlayGrid.get_task_slots()
	for slot in task_slots:
		if slot.global_position.x < global_position.x:
			slot.is_left = true
	
	clear_deck()
	# Generate and place new tasks
	var temp_tasks_list = tasks.duplicate()
	
	for slot in task_slots:
		for task in temp_tasks_list:
			if slot.set_task_type(task):
				temp_tasks_list.erase(task)
				break
		if slot.type != Globals.Task_type.NONE:
			print("Unable to assign anything to slot ", slot, ". There may not be a task that can go there.")
	
	tasks_set_up.emit()

func clear_deck():
	# Clear task slots
	for slot in task_slots:
		slot.clear()

func is_point_in_play_space(point: Vector2):
	return Geometry2D.is_point_in_polygon(point-$PlayArea/CollisionPolygon2D.global_position, $PlayArea/CollisionPolygon2D.polygon)

func get_rowing_tasks():
	var rowing_tasks = []
	for slot in task_slots:
		for task in slot.get_children():
			if task is RowingTask:
				rowing_tasks.append(task)
	
	return rowing_tasks

func get_play_grid_origin():
	return $PlayGrid.global_position
	
func get_size():
	return sprite.get_rect().size
