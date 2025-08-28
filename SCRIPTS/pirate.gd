extends Crew

class_name Pirate

signal died

var is_defeated := false

var worker: Node2D
var assignee: Node2D

func _ready():
	interaction_distance = $InteractableRange/CollisionShape2D.shape.radius
	sprite.material.set_shader_parameter("line_color", Globals.action_color)
	if navigation_agent:
		navigation_agent.set_target_position(global_position)

func _process(delta: float) -> void:
	if not disable_morale:
		change_morale(total_morale_modifier * delta)
		morale_bar.value = morale
	if (current_assignment is Crew and current_assignment.morale <= 0.0) or not current_assignment or not _check_in_range(get_current_target()):
		set_assignment(get_closest_target())

func _attack_state():
	if _check_in_range(get_current_target()):
		$AnimationPlayer.play("fight")
	else:
		current_assignment.remove_morale_modifier(attack_morale_modifier)
		state = State.IDLE

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	interactables.erase(body)

func _on_demoralized():
	remove_from_group("pirate")
	set_assignment(null)
	is_defeated = true
	died.emit()
	queue_free()

func get_closest_target():
	var crew_members = get_tree().get_nodes_in_group("crew")
	var new_target = null
	if not crew_members.is_empty():
		for crew_member in crew_members:
			if crew_member is Crew:
				if crew_member.morale > 0.05:
					if not new_target or global_position.distance_to(new_target.global_position) > global_position.distance_to(crew_member.global_position):
						new_target = crew_member
	return new_target

func set_assignment(new_assignment: Node2D):
	if new_assignment != current_assignment:
		if current_assignment is Crew and attack_morale_modifier:
			current_assignment.remove_morale_modifier(attack_morale_modifier)
		_set_assignment(null)
		state = State.IDLE
		
		if new_assignment == null:
			_set_navigation_position()
		
		_set_assignment(new_assignment)
	elif new_assignment == null:
		_set_navigation_position()

func _start_assignment() -> bool:
	return start_attacking(current_assignment)
	
	set_assignment(null) # TODO: Create cancel/fail animation and function to cancel/fail assignment
	return false

func start_attacking(target: Node2D):
	if current_assignment is Crew:
		current_assignment.add_morale_modifier(attack_morale_modifier)
		state = State.ATTACKING
		return true
	
	return false

func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	var current_target = get_current_target()
	if navigation_agent:
		if current_target:
			if navigation_agent.target_position != current_target.global_position:
				navigation_agent.set_target_position(current_target.global_position)
		if not navigation_agent.is_target_reached():
			direction = global_position.direction_to(navigation_agent.get_next_path_position())
	elif current_target:
		direction = global_position.direction_to(current_target.global_position)
	return direction

func is_targetable():
	return not is_defeated

func _toggle_wandering(is_wandering: bool):
	if is_wandering:
		wander_timer.start(randf_range(1.5, 2.5))
		speed_mod = .25
		_set_navigation_position(true)
	else:
		_set_navigation_position()
		wander_timer.stop()
		speed_mod = 1.0

func _set_navigation_position(is_random: bool = false, new_position: Vector2 = Vector2.ZERO):
	if is_random:
		navigation_agent.set_target_position(NavigationServer2D.map_get_random_point(
			navigation_agent.get_navigation_map(),
			navigation_agent.navigation_layers,
			false))
	else:
		if new_position == Vector2.ZERO:
			if get_current_target():
				navigation_agent.set_target_position(get_current_target().global_position)
			else:
				navigation_agent.set_target_position(global_position)
		else:
			navigation_agent.set_target_position(new_position)

func _on_wander_timer_timeout() -> void:
	_set_navigation_position(true)

func get_current_target():
	if current_assignment is Crew and current_assignment.current_assignment is RowingTask:
		return current_assignment.current_assignment
	
	return current_assignment

# Override assignee and worker setters since we want multiple to be able to work on a pirate at a time
func set_assignee(new_assignee: Worker) -> bool:
	if not is_defeated:
		if not died.is_connected(new_assignee._on_assignment_died):
			died.connect(new_assignee._on_assignment_died)
	return not is_defeated

func set_worker(new_worker: Worker) -> bool:
	if not is_defeated:
		set_assignment(new_worker)
	return not is_defeated
