extends Node

var cur_sound: AudioStreamPlayer

func play(sound_name: String):
	if cur_sound == null:
		if sound_name:
			if get_node(sound_name) is AudioStreamPlayer:
				cur_sound = get_node(sound_name)
				cur_sound.play()
				await cur_sound.finished
				cur_sound = null
			else:
				print("Requested sound ", sound_name, " is either not a child of ", self, ", or not an AudioStreamPlayer")
	else:
		print("Will not play sound ", sound_name, ". Currently playing ", cur_sound)
