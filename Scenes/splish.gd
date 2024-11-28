extends CharacterBody2D

class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:

	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		if direction.y < 0:
			$AnimatedSprite2D.play("walking_up")
		else:
			$AnimatedSprite2D.play("walking_down")
		velocity = direction * SPEED
	else:
		$AnimatedSprite2D.play("idle")
		velocity = Vector2.ZERO
	
	move_and_slide()
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col.get_collider() is Crew:
			col.get_collider().push(col.get_normal().rotated(deg_to_rad(90)) * SPEED * 2)
