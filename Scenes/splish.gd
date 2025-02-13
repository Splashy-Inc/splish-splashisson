extends CharacterBody2D

class_name Player

# Higher value number takes higher priority
enum Selection_priority {
	NONE,
	CREW,
	TASK,
	ROWING,
	OBSTACLE,
	PUDDLE,
	LEAK,
	RAT,
}

const SPEED = 150.0

var interactables: Array[Node2D]
var followers: Array[Crew]

var selection_target: Node2D
var action_target: Node2D

func _process(delta: float) -> void:
	_find_action_target()
	_find_selection_target()

func _physics_process(delta: float) -> void:
	if $AnimationPlayer.current_animation != "pointing_right" or not $AnimationPlayer.is_playing():
		var direction := Input.get_vector("left", "right", "up", "down").normalized()
		if direction:
			if direction.y < 0:
				$AnimationPlayer.play("walking_up")
			else:
				$AnimationPlayer.play("walking_down")
			velocity = direction * SPEED
		else:
			$AnimationPlayer.play("idle")
			velocity = Vector2.ZERO
		
		move_and_slide()
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider() is Crew:
				col.get_collider().push(velocity.normalized().rotated(deg_to_rad(90)) * SPEED * 2)
			
func _input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		if selection_target is Crew:
			add_follower(selection_target)
		elif selection_target is Task or selection_target is Rat:
			if selection_target.worker:
				add_follower(selection_target.worker)
	
	if event.is_action_released("act"):
		if followers.is_empty():
			print("No followers to assign!")
		elif action_target is Task:
			if action_target.worker:
				add_follower(action_target.worker)
			elif action_target.assignee:
				print(action_target, " already assigned to ", action_target.assignee, " !")
			elif followers.is_empty():
				print("No followers to assign to ", action_target, " !")
			else:
				assign_follower(followers.front(), action_target)
		elif action_target is Rat:
			assign_follower(followers.front(), action_target)

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)
	_find_action_target()
	_find_selection_target()

func _on_interactable_range_body_exited(body: Node2D) -> void:
	interactables.erase(body)
	if body == action_target or body == selection_target:
		_refresh_targets()

func place_location_marker():
	var new_marker = Marker2D.new()
	new_marker.global_position = global_position
	get_parent().add_child(new_marker)
	return new_marker

func point(target_position: Vector2):
	$AnimatedSprite2D.flip_h = global_position.direction_to(target_position).x < 0
	$AnimationPlayer.play("pointing_right")
	
func add_follower(new_follower: Crew):
	new_follower.set_assignment(self)
	followers.append(new_follower)
	$SFXManager.play("AddFollower")
	point(new_follower.global_position)
	_refresh_targets()
	
func remove_follower(follower: Crew):
	follower.set_assignment(null)
	followers.erase(follower)
	
func assign_follower(follower: Crew, new_assignment: Node2D):
	follower.set_assignment(new_assignment)
	$SFXManager.play("AssignFollower")
	point(new_assignment.global_position)
	followers.erase(follower)
	_refresh_targets()

func _find_action_target():
	# Don't select action targets if you have no followers
	# Remove this check in https://github.com/Splashy-Inc/splish-splashisson/issues/164
	if not followers.is_empty():
		# Identify closest interactable as action target (not selectable or fully assigned task)
		# TODO: https://github.com/Splashy-Inc/splish-splashisson/issues/165
		var selectables = get_tree().get_nodes_in_group("selectable")
		
		for interactable in interactables:
			if interactable in selectables:
				continue
			if interactable.has_method("is_targetable") and not interactable.is_targetable():
				continue
			
			if action_target:
				var priority_target = _compare_target_priority(action_target, interactable)
				if priority_target:
					_set_action_target(priority_target)
			else:
				_set_action_target(interactable)

func _find_selection_target():
	# Identify closest interactable as selection target (selectable or fully assigned task)
	# TODO: https://github.com/Splashy-Inc/splish-splashisson/issues/165
	var selectables = get_tree().get_nodes_in_group("selectable")
	
	for interactable in interactables:
		if not interactable in selectables or (interactable is Crew and interactable in followers):
			continue
		
		if selection_target:
			var priority_target = _compare_target_priority(selection_target, interactable)
			if priority_target:
				_set_selection_target(priority_target)
		else:
			_set_selection_target(interactable)


func _set_action_target(new_target):
	if action_target and action_target.has_method("set_highlight"):
		action_target.set_highlight(false)
	if new_target and new_target.has_method("set_highlight"):
		new_target.set_highlight(true)
	
	action_target = new_target

func _set_selection_target(new_target):
	if selection_target and selection_target.has_method("set_highlight"):
		selection_target.set_highlight(false)
	if new_target and new_target.has_method("set_highlight"):
		new_target.set_highlight(true)
	
	selection_target = new_target

func _refresh_targets():
	_set_action_target(null)
	_find_action_target()
	_set_selection_target(null)
	_find_selection_target()

func _compare_target_priority(target_1: Node, target_2: Node) -> Node:
	var target_1_priority = _get_target_priority(target_1)
	var target_2_priority = _get_target_priority(target_2)
	
	if target_2_priority > target_1_priority:
		return target_2
	elif target_2_priority == target_1_priority:
		if target_1 is Crew and target_2 is Crew:
			if target_1.state > target_2.state:
				return target_1
			elif target_1.state < target_2.state:
				return target_2
		if target_1.global_position.distance_to(global_position) > target_2.global_position.distance_to(global_position):
			return target_2
	return target_1

# TODO: Figure out a better way to do this
func _get_target_priority(node: Node):
	if node is Rat:
		return Selection_priority.RAT
	elif node is Leak:
		return Selection_priority.LEAK
	elif node is Puddle:
		return Selection_priority.PUDDLE
	elif node is Obstacle:
		return Selection_priority.OBSTACLE
	elif node is RowingTask:
		return Selection_priority.ROWING
	elif node is Task:
		return Selection_priority.TASK
	elif node is Crew:
		return Selection_priority.CREW
	return Selection_priority.NONE
