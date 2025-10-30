extends CargoItem

enum State {
	IDLE,
	SINGING,
	SCREAMING,
}

var state := State.IDLE
@export var screaming_morale_modifier : MoraleModifier
@export var singing_morale_modifier : MoraleModifier
var audience : Array[Crew]

func _ready() -> void:
	sprite = $AnimatedSprite2D

func _process(delta: float) -> void:
	match state:
		State.IDLE:
			sprite.play("idle")
		State.SINGING:
			sprite.play("sing")
			change_health(int(audience.size() * -singing_morale_modifier.rate * 100 * delta))
		State.SCREAMING:
			sprite.play("scream")

func set_sprite_texture(new_texture):
	pass

func get_sprite_texture():
	return cur_data.texture

func _on_host_threats_changed(threats: Array):
	set_state(State.IDLE)
	for threat in threats:
		set_state(State.SINGING)
		if not threat is Crew:
			set_state(State.SCREAMING)
			break

func set_state(new_state: State):
	if new_state != state:
		state = new_state
		match state:
			State.IDLE:
				toggle_singing(false)
				toggle_screaming(false)
			State.SINGING:
				toggle_singing(true)
				toggle_screaming(false)
			State.SCREAMING:
				toggle_singing(false)
				toggle_screaming(true)

func toggle_singing(is_enabled: bool):
	for threat in host_cargo.get_threats():
		if threat is Crew:
			if is_enabled:
				threat.add_morale_modifier(singing_morale_modifier)
				audience.append(threat)
			else:
				threat.remove_morale_modifier(singing_morale_modifier)
				if not audience.is_empty():
					audience.clear()

func toggle_screaming(is_enabled: bool):
	for crew in get_tree().get_nodes_in_group("crew"):
		if crew is Crew:
			if is_enabled:
				crew.add_morale_modifier(screaming_morale_modifier)
			else:
				crew.remove_morale_modifier(screaming_morale_modifier)

func _on_degrade_tick_timer_timeout() -> void:
	if state == State.SINGING:
		change_health(audience.size())
	else:
		change_health(-1)
