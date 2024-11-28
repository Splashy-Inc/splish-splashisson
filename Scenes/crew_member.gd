extends CharacterBody2D

@export var assignment_target: Node2D
@export var follow_distance = 50

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	if assignment_target:
		var distance_to_assignment =  global_position.distance_to(assignment_target.global_position)
		if distance_to_assignment > 5:
			var direction = global_position.direction_to(assignment_target.global_position)
			if (assignment_target is not Player) or (distance_to_assignment > follow_distance):
				velocity = direction * SPEED
				move_and_slide()
		else:
			global_position == assignment_target.global_position

func set_assignment(new_assignment: Node2D):
	assignment_target = new_assignment
