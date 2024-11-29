extends CharacterBody2D

class_name Crew

@export var assignment_target: Node2D
@export var follow_distance = 70

const SPEED = 300.0
var push_velocity = Vector2.ZERO
var following = false

func _physics_process(delta: float) -> void:
	velocity = push_velocity
	push_velocity = Vector2.ZERO
	
	if not ($AnimatedSprite2D.animation == "alert" or $AnimatedSprite2D.animation == "acknowledge") or not $AnimatedSprite2D.is_playing():
		if assignment_target:
			var distance_to_assignment =  global_position.distance_to(assignment_target.global_position)
			if distance_to_assignment > 5:
				var direction = global_position.direction_to(assignment_target.global_position)
				if (assignment_target is not Player) or (distance_to_assignment > follow_distance):
					velocity += direction * SPEED
			else:
				global_position == assignment_target.global_position
		
		if velocity != Vector2.ZERO and push_velocity == Vector2.ZERO:
			if rad_to_deg(velocity.angle()) < -15 and  rad_to_deg(velocity.angle()) > -165:
				$AnimatedSprite2D.play("walking_up")
			else:
				$AnimatedSprite2D.play("walking_down")
		else:
			if following and global_position.direction_to(assignment_target.global_position).y < 0:
				$AnimatedSprite2D.play("idle_up")
			else:
				$AnimatedSprite2D.play("idle_down")
	
	move_and_slide()

func set_assignment(new_assignment: Node2D):
	if assignment_target is Marker2D:
		assignment_target.queue_free()
	
	assignment_target = new_assignment
	
	if assignment_target is Player:
		following = true
		$AnimatedSprite2D.play("alert")
	else:
		following = false
		$AnimatedSprite2D.play("acknowledge")

func push(push_vector: Vector2):
	push_velocity += push_vector
