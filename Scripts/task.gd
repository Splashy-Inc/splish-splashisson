extends StaticBody2D

class_name Task

var assignee: Crew
var worker: Crew

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_assignee(new_assignee: Crew) -> bool:
	if assignee:
		return false
	else:
		assignee = new_assignee
		return true

# This function is intended to be set when the respective crew is in range of the task to begin work
func set_worker(new_worker: Crew) -> bool:
	if new_worker: # Only allow setting assignee if not already taken
		if worker == null:
			assignee = worker
			new_worker.hide_self()
			new_worker.global_position = global_position
			$AnimatedSprite2D.play("active")
		else:
			return false
	elif worker: # Null being passed in means unassigning current assignee, so show them
		assignee = null
		worker.show_self()
		$AnimatedSprite2D.play("idle")
	
	worker = new_worker
	return true
