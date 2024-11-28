extends CharacterBody2D

class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var interactables: Array[Node2D]

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
			
func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("unassign"):
		if interactables.front().has_method("set_assignment"):
			interactables.front().set_assignment(null)
	if Input.is_action_just_pressed("interact"):
		if interactables.front().has_method("set_assignment"):
			interactables.front().set_assignment(self)
	if Input.is_action_just_pressed("location"):
		if interactables.front().has_method("set_assignment"):
			interactables.front().set_assignment(place_location_marker())

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	interactables.erase(body)

func place_location_marker():
	var new_marker = Marker2D.new()
	new_marker.global_position = global_position
	get_parent().add_child(new_marker)
	return new_marker
