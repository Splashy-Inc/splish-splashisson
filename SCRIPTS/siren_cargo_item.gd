extends CargoItem

func _ready() -> void:
	sprite = $AnimatedSprite2D

func set_sprite_texture(new_texture):
	pass

func get_sprite_texture():
	return cur_data.texture
