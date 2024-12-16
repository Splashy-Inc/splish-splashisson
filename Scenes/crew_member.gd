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
	
	if not ($AnimationPlayer.current_animation == "alert" or $AnimationPlayer.current_animation == "acknowledge" or $AnimationPlayer.current_animation == "bail_water") or not $AnimationPlayer.is_playing():
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
			if new_assignment is Puddle:
				new_assignment.died.connect(_on_assigned_puddle_died)
			if new_assignment.set_assignee(self):
				$InteractableRange/CollisionShape2D.set_deferred("disabled", false)
			else:
				print(self, " unable to set self as assignee of ", new_assignment)
				return
		
		following = false
		$AnimationPlayer.play("acknowledge")
	
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
		var puddles = get_tree().get_nodes_in_group("puddle")
		if puddles.is_empty():
			set_assignment(null)
		else:
			var closest_puddle = puddles.front()
			for puddle in puddles:
				if global_position.distance_to(puddle.global_position) < global_position.distance_to(closest_puddle.global_position):
					closest_puddle = puddle
			set_assignment(closest_puddle)
			if global_position.distance_to(closest_puddle.global_position) < $InteractableRange/CollisionShape2D.shape.radius:
				assignment_started.emit()

func _bail_puddle() -> void:
	if current_assignment is Puddle:
		current_assignment.decrease_stage()
		
func _on_assigned_puddle_died():
	stop_bailing()

func _on_assignment_started() -> void:
	if current_assignment is Puddle:
		start_bailing()
