extends Node

func play(sound_name: String):
		if sound_name:
			if get_node(sound_name) is AudioStreamPlayer:
				get_node(sound_name).play()
			else:
				print("Requested sound ", sound_name, " is either not a child of ", self, ", or not an AudioStreamPlayer")
