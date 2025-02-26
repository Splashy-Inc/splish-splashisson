extends Worker

class_name Crew

func _ready():
	interaction_distance = $InteractableRange/CollisionShape2D.shape.radius
	$AnimatedSprite2D.material.set_shader_parameter("line_color", Globals.crew_select_color)

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	interactables.erase(body)

func _on_distraction_timer_timeout() -> void:
	print(self, " is distracted, going for cargo: ", get_tree().get_nodes_in_group("cargo").front())
	set_assignment(get_tree().get_nodes_in_group("cargo").front())

func set_assignment(new_assignment: Node2D):
	state = State.IDLE
	$IdleDistractionTimer.stop()
	$RowingDistractionTimer.stop()
	
	if new_assignment == null or new_assignment is Marker2D:
		state = State.ACKNOWLEDGING
		$IdleDistractionTimer.start()
	elif new_assignment is Player:
		state = State.ALERTED
	else:
		if new_assignment is Task or new_assignment is Rat:
			if new_assignment is Puddle or new_assignment is Leak or new_assignment is Rat:
				new_assignment.died.connect(_on_assignment_died)
			if not new_assignment.set_assignee(self):
				print(self, " unable to set self as assignee of ", new_assignment)
				current_assignment = null
				return
		state = State.ACKNOWLEDGING
	
	_set_assignment(new_assignment)
