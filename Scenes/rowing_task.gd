extends Task

func play_animation(animation_name):	
	$AnimationPlayer.play(animation_name)
	for node in get_tree().get_nodes_in_group("rowing_animation"):
		if node is AnimationPlayer and node.current_animation == "active" and node != $AnimationPlayer:
			$AnimationPlayer.seek(node.current_animation_position, true, true)
			break
