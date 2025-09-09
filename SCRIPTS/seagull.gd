extends Creature

class_name Seagull

func _death_state():
	if target:
		var direction = -_get_direction()
		direction = Vector2(direction.x, -.1).normalized()
		velocity = direction * SPEED * speed_mod
		_set_state(State.DEAD)
		sprite.play("move")
	else:
		target_closest_cargo()
	
	move_and_slide()

func _on_screen_exited() -> void:
	if state == State.DEAD:
		_die()
