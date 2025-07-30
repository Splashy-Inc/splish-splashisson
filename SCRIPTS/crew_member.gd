extends Worker

class_name Crew

@export var is_distracted: bool

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var idle_distraction_timer: Timer = $IdleDistractionTimer
@onready var rowing_distraction_timer: Timer = $RowingDistractionTimer
@onready var wander_timer: Timer = $WanderTimer

func _ready():
	interaction_distance = $InteractableRange/CollisionShape2D.shape.radius
	$AnimatedSprite2D.material.set_shader_parameter("line_color", Globals.crew_select_color)

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	interactables.erase(body)

func _on_distraction_timer_timeout() -> void:
	set_assignment(null)
	_toggle_distracted(true)

func _toggle_distracted(new_is_distracted: bool):
	if new_is_distracted != is_distracted:
		is_distracted = new_is_distracted
		if is_distracted:
			var distractions = get_tree().get_nodes_in_group("distraction")
			var new_distraction = null
			if not distractions.is_empty():
				for distraction in distractions:
					if distraction is Node2D:
						if distraction is CargoItem:
							if distraction.get_parent() is Cargo:
								distraction = distraction.get_parent()
						if not new_distraction or global_position.distance_to(new_distraction.global_position) > global_position.distance_to(distraction.global_position):
							new_distraction = distraction
			if new_distraction:
				set_assignment(new_distraction)
			else:
				_toggle_wandering(true)
		else:
			_toggle_wandering(false)

func set_assignment(new_assignment: Node2D):
	if new_assignment != current_assignment:
		state = State.IDLE
		_toggle_distracted(false)
		idle_distraction_timer.stop()
		rowing_distraction_timer.stop()
		
		if new_assignment == null:
			state = State.ACKNOWLEDGING
			idle_distraction_timer.start()
			_set_navigation_position()
		elif new_assignment is Player:
			state = State.ALERTED
		else:
			if new_assignment is Task or new_assignment is Rat:
				if not new_assignment.set_assignee(self):
					print(self, " unable to set self as assignee of ", new_assignment)
					current_assignment = null
					return
				if new_assignment is Puddle or new_assignment is Leak or new_assignment is Rat:
					new_assignment.died.connect(_on_assignment_died)
				if new_assignment is RowingTask:
					rowing_distraction_timer.start()
				
			state = State.ACKNOWLEDGING
		
		_set_assignment(new_assignment)

func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	if navigation_agent:
		if current_assignment and navigation_agent.target_position != current_assignment.global_position:
			navigation_agent.set_target_position(current_assignment.global_position)
		direction = global_position.direction_to(navigation_agent.get_next_path_position())
	elif current_assignment:
		direction = global_position.direction_to(current_assignment.global_position)
	return direction

func is_targetable():
	if is_in_group("selectable"):
		return true
	else:
		return false

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
			navigation_agent.set_target_position(global_position)
		else:
			navigation_agent.set_target_position(new_position)

func _on_wander_timer_timeout() -> void:
	_set_navigation_position(true)
