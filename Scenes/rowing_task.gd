extends Task

class_name RowingTask

const SPEED_CHANGE = 20

var disabled := false

var threats := []

func play_animation(animation_name):
	if animation_name == "active" and level_completed:
		animation_name = "stop"
	
	$AnimationPlayer.play(animation_name)
	for node in get_tree().get_nodes_in_group("rowing_animation"):
		if animation_name == "stop":
			if node is AnimationPlayer and node.current_animation == "stop" and node != $AnimationPlayer:
				$AnimationPlayer.seek(node.current_animation_position, true, true)
				break
			elif node is AnimationPlayer and node.current_animation == "active" and node != $AnimationPlayer:
				# The calculations below are very specific to how the rowing animation if laid out
				# An changes to either the rowing animation will need to be considered here, respectively
				var anim_position = fmod(node.current_animation_position, 2.0)
				if anim_position > 1.0:
					anim_position = 2.0 - anim_position
				$AnimationPlayer.seek(anim_position, true, true)
				break
		else:
			if node is AnimationPlayer and node.current_animation == "active" and node != $AnimationPlayer:
				$AnimationPlayer.seek(node.current_animation_position, true, true)
				break

func toggle_active(set_active: bool):
	is_active = set_active
	if is_active:
		play_animation("active")
		Globals.boat.change_speed(SPEED_CHANGE)
	else:
		play_animation("idle")
		Globals.boat.change_speed(-SPEED_CHANGE)
		
func stop():
	if $AnimationPlayer.current_animation == "active":
		play_animation("stop")

func set_worker(new_worker: Worker):
	if new_worker:
		add_to_group("selectable")
		$AnimatedSprite2D.material.set_shader_parameter("line_color", Globals.crew_select_color)
	else:
		remove_from_group("selectable")
		$AnimatedSprite2D.material.set_shader_parameter("line_color", Globals.action_color)
	
	return _set_worker(new_worker)

func add_threat(body: Node2D):
	if body is Puddle:
		body.died.connect(_on_threat_died.bind(body))
	threats.append(body)
	modulate = Globals.disabled_modulate
	if assignee:
		assignee.set_assignment(null)
	return true

func remove_threat(body: Node2D):
	threats.erase(body)
	if threats.is_empty():
		modulate = Globals.modulate_reset
	return true

func _on_threat_died(threat: Node2D):
	remove_threat(threat)

func is_targetable() -> bool:
	return threats.is_empty() and not assignee
