extends Node2D

@export var attenuation: float

func _ready():
	# Maximum diagonal that the player can see
	var max_distance = get_viewport_rect().size.length()
	for child in get_children():
		if child is AudioStreamPlayer2D:
			child.max_distance = max_distance
			child.attenuation = attenuation

func play(sound_name: String):
		if sound_name:
			var sound_node = get_node(sound_name)
			if sound_node is AudioStreamPlayer or sound_node is AudioStreamPlayer2D:
				sound_node.play()
			else:
				print("Requested sound ", sound_name, " is either not a child of ", self, ", or not an AudioStreamPlayer/2D")
