extends Worker

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

var followers: Array[Crew]

var selection_target: Node2D
var action_target: Node2D

func _process(delta: float) -> void:
	if not current_assignment and Input.is_action_pressed("act"):
		_find_action_target()
	_find_selection_target()

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	
	match state:
		State.IDLE:
			_idle_state(delta)
		State.MOVING:
			_move_state(delta)
		State.ROWING:
			_rowing_state()
		State.BAILING:
			_bail_state()
		State.PATCHING:
			_patch_state()
		State.ATTACKING:
			_attack_state()

func _idle_state(delta: float):
	_move_state(delta)

func _move_state(delta: float):
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
	if event.is_action_pressed("select"):
		if selection_target is Crew:
			add_follower(selection_target)
		elif selection_target is Task:
			if selection_target.worker:
				add_follower(selection_target.worker)
		return
	
	if event.is_action_pressed("act"):
		if action_target is Task:
			if action_target.assignee:
				print(action_target, " already assigned to ", action_target.assignee, " !")
			elif not followers.is_empty():
				assign_follower(followers.front(), action_target)
		elif action_target is Rat:
			assign_follower(followers.front(), action_target)
		set_assignment(action_target)
		return
	
	if event.is_action_released("act") and current_assignment:
		set_assignment(null)
		return

func _on_interactable_range_body_entered(body: Node2D) -> void:
	interactables.append(body)
	if not current_assignment:
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
	if not current_assignment:
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

func set_assignment(new_assignment: Node2D):
	state = State.IDLE
	
	if new_assignment is Task or new_assignment is Rat:
		if new_assignment is Puddle or new_assignment is Leak or new_assignment is Rat:
			new_assignment.died.connect(_on_assignment_died)
		if not new_assignment.set_assignee(self):
			print(self, " unable to set self as assignee of ", new_assignment)
			current_assignment = null
			return
	
	_set_assignment(new_assignment)
	if current_assignment:
		_start_assignment()
		_set_action_target(current_assignment)

func stop_bailing():
	state = State.IDLE
	if current_assignment is Puddle:
		var closest_puddle = _get_closest(_get_puddles())
		
		set_assignment(closest_puddle)

func _get_puddles() -> Array:
	var puddles = []
	for interactable in interactables:
		if interactable is Puddle:
			puddles.append(interactable)
	return puddles
