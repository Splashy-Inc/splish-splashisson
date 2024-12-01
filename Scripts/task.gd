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
	if new_worker: # Only allow setting worker if not already taken
		if worker == null:
			assignee = worker
			new_worker.hide_self()
			new_worker.global_position = global_position
			play_animation("active")
		else:
			return false
	else:
		assignee = null
		if worker: # Null being passed in means removing current worker, so show them
			worker.show_self()
			play_animation("idle")
	
	worker = new_worker
	return true

func play_animation(animation_name):
	$AnimatedSprite2D.play(animation_name)
