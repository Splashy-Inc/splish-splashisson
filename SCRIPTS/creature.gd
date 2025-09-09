extends CharacterBody2D

class_name Creature

signal spawned
signal died

const SPEED = 50.0

enum State {
	IDLE,
	MOVING,
	ATTACKING,
	DEAD,
}

var state = State.IDLE

var target: Node2D
@export var interaction_radius = 12
var is_selected = false

var worker: Node2D
var assignee: Node2D

@export var health = 3

@export var navigation_agent: NavigationAgent2D

@export var morale_modifier : MoraleModifier
@export var sprite : AnimatedSprite2D
@export var collision_shape : CollisionShape2D
@export var animation_player : AnimationPlayer
@export var sfx_manager : SFXManager

func _ready():
	Globals._on_creature_spawned(self)
	died.connect(Globals._on_creature_died.bind(self))
	sfx_manager.play("SpawnNoise")
	target_closest_cargo()
	spawned.emit()

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
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
	if target and worker == null:
		var direction = _get_direction()
		velocity = direction * SPEED
		_set_state(State.MOVING)
		sprite.play("move")
	else:
		_set_state(State.IDLE)
		sprite.play("idle")
	
	move_and_slide()

func _get_direction() -> Vector2:
	var direction = Vector2.ZERO
	if is_instance_valid(navigation_agent):
		if navigation_agent.target_position != target.global_position:
			navigation_agent.set_target_position(target.global_position)
		direction = global_position.direction_to(navigation_agent.get_next_path_position())
	else:
		direction = global_position.direction_to(target.global_position)
	return direction

func _attack_state():
	animation_player.play("eat")

func _death_state():
	if animation_player.current_animation != "die":
		animation_player.play("die")

func target_closest_cargo():
	for cargo in get_tree().get_nodes_in_group("cargo"):
		if not target:
			target = cargo
		elif global_position.distance_to(cargo.global_position) > global_position.distance_to(target.global_position):
			target = cargo

func _on_interactable_range_body_entered(body: Node2D) -> void:
	if body == target and state != State.DEAD:
		if target is Cargo:
			target.add_threat(self)
			_set_state(State.ATTACKING)

func _on_interactable_range_body_exited(body: Node2D) -> void:
	if body == target and state != State.DEAD:
		if target is Cargo:
			target.remove_threat()
		_set_state(State.IDLE)

func die():
	if target is Cargo:
		target.remove_threat(self)
	_set_state(State.DEAD)
	collision_shape.disabled = true
	died.emit()

func _die():
	queue_free()
	
func on_hit():
	sfx_manager.play("Hit")
	health -= 1
	if health <= 0:
		die()

func set_highlight(is_enable: bool):
	is_selected = is_enable and is_targetable()
	if sprite.material:
		sprite.material.set_shader_parameter("on", is_selected)
	else:
		print(self, " has no highlight material to activate.")

func _set_state(new_state: State):
	if state != State.DEAD:
		state = new_state

func is_targetable() -> bool:
	if state != State.DEAD and (not assignee or assignee is Player):
		return true
	return false

func set_assignee(new_assignee: Worker) -> bool:
	if new_assignee and assignee:
		return false
	else:
		assignee = new_assignee
		return true

# This function is intended to be set when the respective worker is in range of the task to begin work
func set_worker(new_worker: Worker) -> bool:
	if not new_worker:
		set_assignee(new_worker)
	elif new_worker != assignee:
		return false
	worker = new_worker
	return true

func get_morale_modifier() -> MoraleModifier:
	if is_instance_valid(morale_modifier):
		return morale_modifier
	return MoraleModifier.new()
