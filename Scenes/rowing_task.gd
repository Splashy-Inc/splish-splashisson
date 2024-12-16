extends Task

const SPEED_CHANGE = 100

func play_animation(animation_name):	
	$AnimationPlayer.play(animation_name)
	for node in get_tree().get_nodes_in_group("rowing_animation"):
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
