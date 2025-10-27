extends CargoItem

enum State {
	IDLE,
	SINGING,
	SCREAMING,
}

var state := State.IDLE

func _ready() -> void:
	sprite = $AnimatedSprite2D

func _process(delta: float) -> void:
	match state:
		State.IDLE:
			sprite.play("idle")
		State.SINGING:
			sprite.play("sing")
		State.SCREAMING:
			sprite.play("scream")

func set_sprite_texture(new_texture):
	pass

func get_sprite_texture():
	return cur_data.texture

func _on_host_threatened_changed(is_host_threatened: bool):
	if is_host_threatened:
		state = State.SINGING
		for threat in host_cargo.get_threats():
			if not threat is Crew:
				state = State.SCREAMING
	else:
		state = State.IDLE
