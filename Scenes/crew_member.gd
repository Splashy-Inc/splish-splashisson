extends CharacterBody2D

class_name Crew

signal assignment_started

@export var test_assignment: Node2D
@export var current_assignment: Node2D
@export var follow_distance = 40

const SPEED = 150.0
var push_velocity = Vector2.ZERO
var following = false

var is_selected = false

func _physics_process(delta: float) -> void:
	velocity = push_velocity
	push_velocity = Vector2.ZERO
	
	if not ($AnimationPlayer.current_animation == "alert" or $AnimationPlayer.current_animation == "acknowledge" or $AnimationPlayer.current_animation == "bail_water" or $AnimationPlayer.current_animation == "patch_leak") or not $AnimationPlayer.is_playing():
		if current_assignment:
			var distance_to_assignment = global_position.distance_to(current_assignment.global_position)
			if current_assignment is Task:
				if distance_to_assignment >= current_assignment.interaction_radius:
					var direction = global_position.direction_to(current_assignment.global_position)
					velocity += direction * SPEED
			else:
				if distance_to_assignment > 5:
					var direction = global_position.direction_to(current_assignment.global_position)
					if (current_assignment is not Player) or (distance_to_assignment > follow_distance):
						velocity += direction * SPEED
				else:
					global_position == current_assignment.global_position
		
		if velocity != Vector2.ZERO and push_velocity == Vector2.ZERO:
			if rad_to_deg(velocity.angle()) < -15 and  rad_to_deg(velocity.angle()) > -165:
				$AnimationPlayer.play("walking_up")
			else:
				$AnimationPlayer.play("walking_down")
		else:
			if following and global_position.direction_to(current_assignment.global_position).y < 0:
				$AnimationPlayer.play("idle_up")
			else:
				$AnimationPlayer.play("idle_down")
	
	move_and_slide()

func set_assignment(new_assignment: Node2D):
	# TODO: Figure out if we want crew to immediately turn on interactable range
	#   If we don't wait for acknowledgement animation to finish and crew is already close enough,
	#   they will immediately start working. Might be nice for the player, TBD in playtesting.
	$InteractableRange/CollisionShape2D.set_deferred("disabled", true)
	
	if new_assignment is Player:
		following = true
		$AnimationPlayer.play("alert")
	else:
		if new_assignment is Task:
			if new_assignment is Puddle or new_assignment is Leak:
				new_assignment.died.connect(_on_assignment_died)
			if new_assignment.set_assignee(self):
				$InteractableRange/CollisionShape2D.set_deferred("disabled", false)
			else:
				print(self, " unable to set self as assignee of ", new_assignment)
				current_assignment = null
				return
		
		following = false
		$AnimationPlayer.play("acknowledge")
	
	if current_assignment:
		if current_assignment is Marker2D:
			current_assignment.queue_free()
		elif current_assignment is Task:
			current_assignment.set_worker(null)
	
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
	if body == current_assignment and body is Task:
		if body.set_worker(self):
			assignment_started.emit()
		else:
			set_assignment(null) # TODO: Create cancel/fail animation and function to cancel/fail assignment

func set_highlight(is_enable: bool):
	is_selected = is_enable
	reset_highlight()

func reset_highlight():
	$AnimatedSprite2D.material.set_shader_parameter("on", is_selected)

func start_bailing():
	if current_assignment is Puddle:
		$AnimationPlayer.play("bail_water")
	
func stop_bailing():
	if current_assignment is Puddle:
		$AnimationPlayer.play("idle_down")
		var closest_puddle = _get_closest(get_tree().get_nodes_in_group("puddle"))
		
		set_assignment(closest_puddle)
		
		if closest_puddle and global_position.distance_to(closest_puddle.global_position) < $InteractableRange/CollisionShape2D.shape.radius:
			assignment_started.emit()
		

func _bail_puddle() -> void:
	if current_assignment is Puddle:
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
	if current_assignment is Leak:
		$LeakPatchTimer.start()
		$AnimationPlayer.play("patch_leak")
		
func stop_patching():
	if current_assignment is Leak:
		$AnimationPlayer.play("idle_down")
		var closest_leak = _get_closest(get_tree().get_nodes_in_group("leak"))
		
		set_assignment(closest_leak)
		
		if closest_leak and global_position.distance_to(closest_leak.global_position) < $InteractableRange/CollisionShape2D.shape.radius:
			assignment_started.emit()

func _patch_leak() -> void:
	if current_assignment and current_assignment is Leak:
		current_assignment.patch()

func _on_assignment_started() -> void:
	if current_assignment is Puddle:
		start_bailing()
	elif current_assignment is Leak:
		start_patching()

func _get_closest(nodes: Array) -> Node2D:
	if nodes.is_empty():
		return null
	else:
		var closest_node = nodes.front()
		for node in nodes:
			if global_position.distance_to(node.global_position) < global_position.distance_to(closest_node.global_position):
				closest_node = node
		return closest_node
