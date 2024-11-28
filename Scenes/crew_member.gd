extends CharacterBody2D

class_name Crew

@export var assignment_target: Node2D
@export var follow_distance = 70

const SPEED = 300.0
var push_velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	velocity = push_velocity
	push_velocity = Vector2.ZERO
	if assignment_target:
		var distance_to_assignment =  global_position.distance_to(assignment_target.global_position)
		if distance_to_assignment > 5:
			var direction = global_position.direction_to(assignment_target.global_position)
			if (assignment_target is not Player) or (distance_to_assignment > follow_distance):
				velocity += direction * SPEED
		else:
			global_position == assignment_target.global_position
	
	move_and_slide()

func set_assignment(new_assignment: Node2D):
	assignment_target = new_assignment

func push(push_vector: Vector2):
	push_velocity += push_vector
