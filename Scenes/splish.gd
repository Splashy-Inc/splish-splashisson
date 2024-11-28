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
