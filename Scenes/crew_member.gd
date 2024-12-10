extends CharacterBody2D

class_name Crew

signal task_started

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
	
	if not ($AnimationPlayer.current_animation == "alert" or $AnimationPlayer.current_animation == "acknowledge") or not $AnimationPlayer.is_playing():
		if current_assignment:
			var distance_to_assignment =  global_position.distance_to(current_assignment.global_position)
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
			task_started.emit()
		else:
			set_assignment(null) # TODO: Create cancel/fail animation and function to cancel/fail assignment

func set_highlight(is_enable: bool):
	is_selected = is_enable
	reset_highlight()

func reset_highlight():
	$AnimatedSprite2D.material.set_shader_parameter("on", is_selected)
