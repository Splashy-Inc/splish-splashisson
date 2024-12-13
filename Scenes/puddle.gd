extends Task

class_name Puddle

enum Stage {
	SMALL,
	MEDIUM,
	LARGE,
}

var stage = Stage.LARGE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	worker.stop_bailing()
	worker.set_assignment(null)
	queue_free()

func set_worker(new_worker: Crew) -> bool:
	if new_worker: # Only allow setting worker if not already taken
		if worker == null:
			assignee = worker
			new_worker.start_bailing()
		else:
			return false
	else:
		assignee = null
	
	worker = new_worker
	return true
