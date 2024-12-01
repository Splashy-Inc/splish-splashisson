extends CharacterBody2D

class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var interactables: Array[Node2D]
var followers: Array[Crew]

func _physics_process(delta: float) -> void:
	if $AnimatedSprite2D.animation != "pointing_right" or not $AnimatedSprite2D.is_playing():
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
				col.get_collider().push(velocity.normalized().rotated(deg_to_rad(90)) * SPEED * 2)
			
func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		var action_target = _get_action_target()
		if action_target is Crew:
			add_follower(action_target)
		elif action_target is Task:
			if action_target.worker:
				add_follower(action_target.worker)
			elif action_target.assignee:
				print(action_target, " already assigned to ", action_target.assignee, " !")
			elif followers.is_empty():
				print("No followers to assign to ", action_target, " !")
			else:
				assign_follower(followers.front(), action_target)
		
	if Input.is_action_just_pressed("unassign"):
		if followers.is_empty():
			print("No followers to unassign!")
		else:
			remove_follower(followers.front())
	
	if Input.is_action_just_pressed("location"):
		if followers.is_empty():
			print("No followers to assign to location!")
		else:
			assign_follower(followers.front(), place_location_marker())

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	interactables.erase(body)

func place_location_marker():
	var new_marker = Marker2D.new()
	new_marker.global_position = global_position
	get_parent().add_child(new_marker)
	return new_marker

func point(target_position: Vector2):
	$AnimatedSprite2D.flip_h = global_position.direction_to(target_position).x < 0
	$AnimatedSprite2D.play("pointing_right")
	
func add_follower(new_follower: Crew):
	new_follower.set_assignment(self)
	followers.append(new_follower)
	$SFXManager.play("AddFollower")
	point(new_follower.global_position)
	
func remove_follower(follower: Crew):
	follower.set_assignment(null)
	followers.erase(follower)
	
func assign_follower(follower: Crew, new_assignment: Node2D):
	follower.set_assignment(new_assignment)
	$SFXManager.play("AssignFollower")
	point(new_assignment.global_position)
	followers.erase(follower)
	
func _get_action_target():
	# Identify closest interactable as action target
	# TODO: Allow player to cycle through interactable targets
	var action_target
	for interactable in interactables:
		if not interactable is Crew or not interactable in followers:
			# TODO: Add in prioritizing crew members over tasks since crew members can get player stuck
			if action_target:
				if action_target.global_position.distance_to(global_position) > interactable.global_position.distance_to(global_position):
					action_target = interactable
			else:
				action_target = interactable
	
	return action_target
