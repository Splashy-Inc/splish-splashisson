extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
