extends Worker

class_name Pirate

@export var is_distracted: bool
var is_defeated := false

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var wander_timer: Timer = $WanderTimer
@onready var morale_bar: ProgressBar = $MoraleBar

var morale := 1.0
var morale_modifiers : Array[MoraleModifier]
var total_morale_modifier := 0.0
@export var morale_modifier : MoraleModifier

func _ready():
	interaction_distance = $InteractableRange/CollisionShape2D.shape.radius
	sprite.material.set_shader_parameter("line_color", Globals.action_color)
	if navigation_agent:
		navigation_agent.set_target_position(global_position)

func _process(delta: float) -> void:
	if (current_assignment is Crew and current_assignment.morale <= 0.0) or not current_assignment or not _check_in_range(get_current_target()):
		set_assignment(get_closest_target())

func _attack_state():
	if _check_in_range(get_current_target()):
		$AnimationPlayer.play("fight")
	else:
		current_assignment.remove_morale_modifier(morale_modifier)
		state = State.IDLE

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	interactables.erase(body)

func _on_defeated():
		set_assignment(null)
		is_defeated = true

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
		if current_assignment is Crew and morale_modifier:
			current_assignment.remove_morale_modifier(morale_modifier)
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
		current_assignment.add_morale_modifier(morale_modifier)
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
	
func add_morale_modifier(modifier: MoraleModifier):
	if not modifier in morale_modifiers:
		morale_modifiers.append(modifier)
	update_morale_total_modifier()

func remove_morale_modifier(modifier: MoraleModifier):
	morale_modifiers.erase(modifier)
	update_morale_total_modifier()

func update_morale_total_modifier():
	total_morale_modifier = get_total_morale_modifier()

func get_total_morale_modifier() -> float:
	var total_modifier := 0.0
	for modifier in morale_modifiers:
		total_modifier += modifier.rate
	return total_modifier

func change_morale(change):
	morale = clamp(morale + change, 0.0, 1.0)
	if morale <= 0.0:
		_on_defeated()

func get_current_target():
	if current_assignment is Crew and current_assignment.current_assignment is RowingTask:
		return current_assignment.current_assignment
	
	return current_assignment
