extends Node

func play(sound_name: String):
		if sound_name:
			var sound_node = get_node(sound_name)
			if sound_node is AudioStreamPlayer or sound_node is AudioStreamPlayer2D:
				sound_node.play()
			else:
				print("Requested sound ", sound_name, " is either not a child of ", self, ", or not an AudioStreamPlayer/2D")
