extends Worker

class_name Crew

signal distracted

@export var is_distracted: bool

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var wander_timer: Timer = $WanderTimer
@onready var morale_bar: ProgressBar = $MoraleBar

@export var max_morale := 1.5
var morale := max_morale
var morale_modifiers : Array[MoraleModifier]
var total_morale_modifier := 0.0
@export var idle_modifier : MoraleModifier
var disable_morale := false # For tutorial

func _ready():
	interaction_distance = $InteractableRange/CollisionShape2D.shape.radius
	sprite.material.set_shader_parameter("line_color", Globals.crew_select_color)
	if navigation_agent:
		navigation_agent.set_target_position(global_position)
	
	morale_bar.set_max(max_morale)

func _process(delta: float) -> void:
	if not disable_morale:
		change_morale(total_morale_modifier * delta)
		morale_bar.value = morale

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	interactables.erase(body)

func _on_demoralized() -> void:
	_toggle_distracted(true)

func _toggle_distracted(new_is_distracted: bool):
	is_distracted = new_is_distracted
	if is_distracted:
		distracted.emit()
		var new_distraction = get_closest_distraction()
		if new_distraction:
			set_assignment(new_distraction)
			_toggle_wandering(false)
		else:
			set_assignment(null)
			_toggle_wandering(true)
	else:
		_toggle_wandering(false)

func get_closest_distraction():
	var distractions = get_tree().get_nodes_in_group("distraction")
	var new_distraction = null
	if not distractions.is_empty():
		for distraction in distractions:
			if distraction is Node2D:
				if distraction is CargoItem:
					distraction = distraction.get_host()
				if not new_distraction or global_position.distance_to(new_distraction.global_position) > global_position.distance_to(distraction.global_position):
					new_distraction = distraction
	return new_distraction

func set_assignment(new_assignment: Node2D):
	if new_assignment != current_assignment:
		remove_morale_modifier(idle_modifier)
		if is_instance_valid(current_assignment) and current_assignment.has_method("get_morale_modifier"):
			remove_morale_modifier(current_assignment.get_morale_modifier())
		_set_assignment(null)
		state = State.IDLE
		_toggle_distracted(false)
		
		if new_assignment == null:
			state = State.ACKNOWLEDGING
			add_morale_modifier(idle_modifier)
			_set_navigation_position()
		elif new_assignment is Player:
			state = State.ALERTED
			change_morale(max_morale)
		else:
			if new_assignment is Task or new_assignment is Creature or new_assignment is Pirate:
				if not new_assignment.set_assignee(self):
					print(self, " unable to set self as assignee of ", new_assignment, ". Going idle.")
					_set_assignment(null)
					add_morale_modifier(idle_modifier)
					return
				if new_assignment is Puddle or new_assignment is Leak or new_assignment is Creature:
					new_assignment.died.connect(_on_assignment_died)
				if new_assignment.has_method("get_morale_modifier"):
					add_morale_modifier(new_assignment.get_morale_modifier())
				
			state = State.ACKNOWLEDGING
		
		_set_assignment(new_assignment)
	elif new_assignment == null:
		_set_navigation_position()

func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	if navigation_agent:
		if current_assignment:
			if navigation_agent.target_position != current_assignment.global_position:
				navigation_agent.set_target_position(current_assignment.global_position)
		if not navigation_agent.is_target_reached():
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
			if current_assignment:
				navigation_agent.set_target_position(current_assignment.global_position)
			else:
				navigation_agent.set_target_position(global_position)
		else:
			navigation_agent.set_target_position(new_position)

func _on_wander_timer_timeout() -> void:
	_set_navigation_position(true)
	_toggle_distracted(true)
	
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
	morale = clamp(morale + change, 0.0, max_morale)
	if not is_distracted and morale <= 0.0:
		_on_demoralized()
