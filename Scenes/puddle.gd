extends Task

class_name Puddle

signal died

enum Stage {
	SMALL,
	MEDIUM,
	LARGE,
}

const SPEED_CHANGE = -50

var stage = Stage.SMALL

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

# Override assignee and worker setters since we want multiple to be able to work on a puddle at a time
func set_assignee(new_assignee: Crew) -> bool:
	return true

func set_worker(new_worker: Crew) -> bool:
	return true
