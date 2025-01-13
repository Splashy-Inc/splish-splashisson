extends CharacterBody2D

class_name Crew

@export var test_assignment: Node2D
@export var current_assignment: Node2D

const SPEED = 150.0
var push_velocity = Vector2.ZERO

var is_selected = false

# State order is used in selection priority, highest value being what takes precedence
enum State {
	ALERTED,
	ACKNOWLEDGING,
	MOVING, # Don't want to easily interrupt crew on their way to tasks
	ATTACKING, # Often times, attacking is dealing with very important cargo threat
	BAILING,
	PATCHING,
	ROWING,
	IDLE,
	DISTRACTED,
}

var state = State.IDLE

var interaction_distance: float
var interactables = []

func _ready():
	interaction_distance = $InteractableRange/CollisionShape2D.shape.radius

func _physics_process(delta: float) -> void:
	if state != State.DISTRACTED:
		velocity = push_velocity
	push_velocity = Vector2.ZERO
	
	match state:
		State.IDLE:
			_idle_state()
		State.MOVING:
			_move_state(delta)
		State.ALERTED:
			_alert_state()
		State.ACKNOWLEDGING:
			_acknowledge_state()
		State.ROWING:
			_rowing_state()
		State.BAILING:
			_bail_state()
		State.PATCHING:
			_patch_state()
		State.DISTRACTED:
			_distract_state()
		State.ATTACKING:
			_attack_state()
	
	move_and_slide()

func _idle_state():
	if current_assignment:
		if _check_in_range(current_assignment):
			if current_assignment is Player:
				if global_position.direction_to(current_assignment.global_position).y < 0:
					$AnimationPlayer.play("idle_up")
				else:
					$AnimationPlayer.play("idle_down")
			else:
				_start_assignment()
		else:
			state = State.MOVING
	else:
		$AnimationPlayer.play("idle_down")

func _move_state(delta: float):
	if _check_in_range(current_assignment):
		state = State.IDLE
		if not current_assignment is Player:
			_start_assignment()
	else:
		if current_assignment:
			var direction = global_position.direction_to(current_assignment.global_position)
			velocity += direction * SPEED
		
		if velocity != Vector2.ZERO and push_velocity == Vector2.ZERO:
			if rad_to_deg(velocity.angle()) < -15 and  rad_to_deg(velocity.angle()) > -165:
				$AnimationPlayer.play("walking_up")
			else:
				$AnimationPlayer.play("walking_down")

func _alert_state():
	$AnimationPlayer.play("alert")

func _acknowledge_state():
	$AnimationPlayer.play("acknowledge")

func _rowing_state():
	$AnimationPlayer.play("idle_down")

func _bail_state():
	$AnimationPlayer.play("bail_water")

func _patch_state():
	$AnimationPlayer.play("patch_leak")

func _distract_state():
	if current_assignment is Cargo:
		if current_assignment.cargo_type == Cargo.Cargo_type.MEAT:
			$AnimationPlayer.play("eating")

func _attack_state():
	if current_assignment is Rat:
		if $AttackTimer.is_stopped():
			$AttackTimer.start()
		$AnimationPlayer.play("stomping")

func _on_animation_finished():
	state = State.IDLE

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
			if new_assignment is Puddle or new_assignment is Leak:
				new_assignment.died.connect(_on_assignment_died)
			if not new_assignment.set_assignee(self):
				print(self, " unable to set self as assignee of ", new_assignment)
				current_assignment = null
				return
		state = State.ACKNOWLEDGING
	
	if current_assignment:
		if current_assignment is Marker2D:
			current_assignment.queue_free()
		elif current_assignment is Task:
			current_assignment.set_worker(null)
		elif current_assignment is Rat:
			current_assignment.set_worker(null)
			$AttackTimer.stop()
		elif current_assignment is Cargo:
			current_assignment.remove_threat(self)
	
	current_assignment = new_assignment

func push(push_vector: Vector2):
	push_velocity += push_vector
	
func hide_self():
	hide()
	$CollisionShape2D.set_deferred("disabled", true)

func show_self():
	show()
	$CollisionShape2D.set_deferred("disabled", false)

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	interactables.erase(body)

func set_highlight(is_enable: bool):
	is_selected = is_enable
	reset_highlight()

func reset_highlight():
	$AnimatedSprite2D.material.set_shader_parameter("on", is_selected)

func start_rowing():
	if current_assignment is RowingTask and current_assignment.set_worker(self):
		state = State.ROWING
		$RowingDistractionTimer.start()
		return true
	return false

func start_bailing():
	if current_assignment is Puddle and current_assignment.set_worker(self):
		state = State.BAILING
		return true
	return false
	
func stop_bailing():
	state = State.IDLE
	if current_assignment is Puddle:
		var closest_puddle = _get_closest(get_tree().get_nodes_in_group("puddle"))
		
		set_assignment(closest_puddle)
		
		if closest_puddle and _check_in_range(closest_puddle):
			_start_assignment()
		

func _bail_puddle() -> void:
	if current_assignment and current_assignment is Puddle:
		current_assignment.decrease_stage()
		
func _on_assignment_died():
	if current_assignment != null:
		if current_assignment is Puddle:
			stop_bailing()
		elif current_assignment is Leak:
			stop_patching()
	else:
		set_assignment(null)
	
func start_patching():
	if current_assignment is Leak and current_assignment.set_worker(self):
		state = State.PATCHING
		$LeakPatchTimer.start()
		return true
	return false
		
func stop_patching():
	state = State.IDLE
	if current_assignment is Leak:
		var closest_leak = _get_closest(get_tree().get_nodes_in_group("leak"))
		
		set_assignment(closest_leak)
		
		if closest_leak and _check_in_range(closest_leak):
			_start_assignment()

func _patch_leak() -> void:
	if current_assignment and current_assignment is Leak:
		current_assignment.patch()

func start_distraction():
	if current_assignment is Cargo and current_assignment.add_threat(self):
		state = State.DISTRACTED
		return true
	return false

func start_stomping_rat():
	if current_assignment is Rat and current_assignment.set_worker(self):
		state = State.ATTACKING
		return true
	return false

func _start_assignment() -> bool:
	if current_assignment is Cargo and state != State.DISTRACTED:
		return start_distraction()
	elif current_assignment is RowingTask:
		return start_rowing()
	elif current_assignment is Puddle:
		return start_bailing()
	elif current_assignment is Leak:
		return start_patching()
	elif current_assignment is Rat:
		return start_stomping_rat()
	
	set_assignment(null) # TODO: Create cancel/fail animation and function to cancel/fail assignment
	return false

func _get_closest(nodes: Array) -> Node2D:
	if nodes.is_empty():
		return null
	else:
		var closest_node = nodes.front()
		for node in nodes:
			if global_position.distance_to(node.global_position) < global_position.distance_to(closest_node.global_position):
				closest_node = node
		return closest_node

func _on_distraction_timer_timeout() -> void:
	print(self, " is distracted, going for cargo: ", get_tree().get_nodes_in_group("cargo").front())
	set_assignment(get_tree().get_nodes_in_group("cargo").front())

func _check_in_range(node: Node2D):
	if node and (node in interactables or global_position.distance_to(node.global_position) < interaction_distance):
		return true
	return false

func _on_attack_timer_timeout() -> void:
	if current_assignment.has_method("die"):
		current_assignment.die()
		set_assignment(null)
	else:
		print(current_assignment, " cannot die. Attacking does nothing.")
