extends CharacterBody2D

class_name Rat

const SPEED = 50.0

enum State {
	IDLE,
	MOVING,
	ATTACKING,
	DEAD,
}

var state = State.IDLE

var target: Cargo
@export var hole: StaticBody2D
@export var interaction_radius: int
var is_selected = false

func _ready():
	target_closest_cargo()

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			_move_state(delta)
		State.MOVING:
			_move_state(delta)
		State.ATTACKING:
			_attack_state()
		State.DEAD:
			_death_state()

func _move_state(delta: float):
	if target:
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * SPEED
		_set_state(State.MOVING)
		$AnimatedSprite2D.play("move")
	else:
		_set_state(State.IDLE)
		$AnimatedSprite2D.play("idle")
	
	move_and_slide()

func _attack_state():
	$AnimatedSprite2D.play("eat")

func _death_state():
	if not $AnimatedSprite2D.animation == "die":
		$AnimatedSprite2D.play("die")

func target_closest_cargo():
	for cargo in get_tree().get_nodes_in_group("cargo"):
		if not target:
			target = cargo
		elif global_position.distance_to(cargo.global_position) > global_position.distance_to(target.global_position):
			target = cargo

func _on_interactable_range_body_entered(body: Node2D) -> void:
	if body == target and state != State.DEAD:
		target.add_threat(self)
		_set_state(State.ATTACKING)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	if body == target and state != State.DEAD:
		target.remove_threat(self)
		_set_state(State.IDLE)

func die():
	if target:
		target.remove_threat(self)
	_set_state(State.DEAD)

func set_highlight(is_enable: bool):
	is_selected = is_enable and is_targetable()
	if $AnimatedSprite2D.material:
		$AnimatedSprite2D.material.set_shader_parameter("on", is_selected)
	else:
		print(self, " has no highlight material to activate.")

func _set_state(new_state: State):
	if state != State.DEAD:
		state = new_state

func is_targetable() -> bool:
	if state != State.DEAD:
		return true
	return false
