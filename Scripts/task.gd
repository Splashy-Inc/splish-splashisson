extends StaticBody2D

class_name Task

var assignee: Crew
var worker: Crew

var is_active = false

var is_selected = false
@export var interaction_radius: int

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
			toggle_active(true)
		else:
			return false
	else:
		assignee = null
		if worker: # Null being passed in means removing current worker, so show them
			worker.show_self()
			toggle_active(false)
	
	worker = new_worker
	return true

func play_animation(animation_name):
	$AnimatedSprite2D.play(animation_name)
	
func set_highlight(is_enable: bool):
	is_selected = is_enable
	if $AnimatedSprite2D.material:
		$AnimatedSprite2D.material.set_shader_parameter("on", is_enable)
	else:
		print(self, " has no highlight material to activate.")

func toggle_active(set_active: bool):
	is_active = set_active
	if is_active:
		play_animation("active")
	else:
		play_animation("idle")
