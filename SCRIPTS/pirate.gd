extends Crew

class_name Pirate

signal died

enum Type {
	NONE,
	SAW,
	HAMMER
}

@export var type : Type

var is_defeated := false

var worker: Node2D
var assignee: Node2D

@export var defeated_color: Color

@export var has_boarded := false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var sprite_container: Node2D
@export var sprite_frame_sets : Array[SpriteFrames]
@onready var splash_sprite: AnimatedSprite2D = $Sprites/Splash

var splash_point: Marker2D
var board_point: Marker2D
@export var jump_curve : Curve
var jump_distance := 150
var target_boat : Boat

func _ready():
	interaction_distance = $InteractableRange/CollisionShape2D.shape.radius
	set_highlight(false, Globals.action_color)
	if navigation_agent:
		navigation_agent.set_target_position(global_position)
	
	if has_boarded:
		add_to_group("pirate")
		collision_shape.disabled = false
		morale_bar.show()
	else:
		remove_from_group("pirate")
		collision_shape.disabled = true
		morale_bar.hide()
	
	set_type(type)

func _process(delta: float) -> void:
	if not disable_morale:
		change_morale(total_morale_modifier * delta)
		morale_bar.value = morale

	if has_boarded and not current_assignment is Player and ((current_assignment is Crew and current_assignment.morale <= 0.0) or not _check_in_range(get_current_target())):
		set_assignment(get_closest_target())

func _start_assignment_player():
	_start_assignment()

func _attack_state():
	if _check_in_range(get_current_target()):
		$AnimationPlayer.play("fight")
	else:
		if current_assignment.has_method("remove_morale_modifier"):
			current_assignment.remove_morale_modifier(attack_morale_modifier)
		state = State.IDLE

func _dying_state(delta: float):
	if _check_in_range(get_current_target()):
		if splash_sprite.visible:
			splash_sprite.offset.y += Globals.boat.speed * delta
		else:
			_splash()
	else:
		_move_state(delta)
		if global_position.distance_to(splash_point.global_position) <= 150:
			if sprite is AnimatedSprite2D:
				sprite.offset.y = -jump_curve.sample(global_position.distance_to(splash_point.global_position)/150)
			$AnimationPlayer.play("jump")

func _boarding_state(delta: float):
	if _check_in_range(get_current_target()):
		speed_mod = 1.0
		set_assignment(null)
		add_to_group("pirate")
		collision_shape.disabled = false
		morale_bar.show()
		has_boarded = true
		state = State.IDLE
	else:
		_move_state(delta)
		if sprite is AnimatedSprite2D:
			sprite.offset.y = -jump_curve.sample(global_position.distance_to(board_point.global_position)/jump_distance)
		$AnimationPlayer.play("jump")

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	interactables.erase(body)

func _on_demoralized():
	if not is_defeated:
		remove_from_group("pirate")
		died.emit()
		morale_bar.hide()
		set_highlight(true, defeated_color)
		is_defeated = true
		splash_point = _generate_jump_marker(Vector2(Globals.boat.global_position.x + 250, global_position.y))
		set_assignment(splash_point)
		state = State.DYING
		speed_mod = 1.5
		collision_shape.disabled = true

func _splash():
	sprite.hide()
	splash_sprite.show()
	splash_sprite.play("splash")
	await splash_sprite.animation_finished
	splash_point.queue_free()
	queue_free()

func set_highlight(is_enable: bool, new_color: Color = Color.WHITE):
	if not is_defeated:
		if new_color != Color.WHITE:
			sprite.material.set_shader_parameter("line_color", new_color)
		is_selected = is_enable
		reset_highlight()

func get_closest_target():
	if is_defeated:
		return splash_point
	else:
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
	if current_assignment is Worker:
		if current_assignment is Crew:
			current_assignment.add_morale_modifier(attack_morale_modifier)
		state = State.ATTACKING
		return true
	
	return false

func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	var current_target = get_current_target()
	if navigation_agent and current_target and not current_target is Marker2D:
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

func _generate_jump_marker(jump_point: Vector2):
	var new_jump_point = Marker2D.new()
	get_parent().add_child(new_jump_point)
	new_jump_point.global_position = jump_point
	return new_jump_point

func board_boat(boat: Boat, is_right: bool = false):
	target_boat = boat
	if is_right:
		board_point = _generate_jump_marker(Vector2(target_boat.global_position.x + 64, global_position.y))
		speed_mod = 1.5
	else:
		board_point = _generate_jump_marker(Vector2(target_boat.global_position.x - 64, global_position.y))
		speed_mod = 1.0
	target_boat.add_obstacle(board_point)
	jump_distance = abs(global_position.x - board_point.global_position.x)
	set_assignment(board_point)
	target_boat.add_obstacle(self)
	state = State.BOARDING

func set_type(new_type: Type):
	type = new_type
	sprite.sprite_frames = sprite_frame_sets[type]
