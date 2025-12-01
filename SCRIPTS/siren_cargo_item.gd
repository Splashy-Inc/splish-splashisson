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

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var aura_animation_player: AnimationPlayer = $SingingArea/AuraAnimationPlayer

func _ready() -> void:
	sprite = $AnimatedSprite2D

func _process(delta: float) -> void:
	match state:
		State.IDLE:
			if audience.is_empty():
				animation_player.play("idle")
			else:
				set_state(State.SINGING)
		State.SINGING:
			if audience.is_empty():
				set_state(State.IDLE)
			else:
				animation_player.play("sing")
				change_health(int(audience.size() * -singing_morale_modifier.rate * 100 * delta))
		State.SCREAMING:
			animation_player.play("scream")

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
	for target in audience:
		if target is Crew:
			if is_enabled:
				target.add_morale_modifier(singing_morale_modifier)
			else:
				target.remove_morale_modifier(singing_morale_modifier)

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

func _on_singing_area_body_entered(body: Node2D) -> void:
	if body is Crew and not body in audience:
		audience.append(body)

func _on_singing_area_body_exited(body: Node2D) -> void:
	audience.erase(body)
