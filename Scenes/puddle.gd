extends Task

class_name Puddle

signal died

enum Stage {
	SMALL,
	MEDIUM,
	LARGE,
}

const SPEED_CHANGE = -50

var stage = Stage.LARGE

var affecting_speed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Globals.boat:
		Globals.boat_ready.connect(_set_stage)
	else:
		_set_stage()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_stage():
	match stage:
		Stage.SMALL:
			$AnimatedSprite2D.play("small")
		Stage.MEDIUM:
			$AnimatedSprite2D.play("medium")
		Stage.LARGE:
			$AnimatedSprite2D.play("large")
			affecting_speed = true
			Globals.boat.change_speed(SPEED_CHANGE)

func increase_stage():
	if stage < Stage.LARGE:
		stage += 1
		_set_stage()
	# TODO: Else, spread

func decrease_stage():
	if stage <= Stage.SMALL:
		die()
	else:
		stage -= 1
		_set_stage()

func die():
	if affecting_speed:
		Globals.boat.change_speed(-SPEED_CHANGE)
	remove_from_group("puddle")
	died.emit()
	queue_free()

func set_worker(new_worker: Crew) -> bool:
	if new_worker: # Only allow setting worker if not already taken
		if worker == null:
			assignee = worker
		else:
			return false
	else:
		assignee = null
	
	worker = new_worker
	return true
