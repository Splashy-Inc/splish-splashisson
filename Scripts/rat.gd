extends CharacterBody2D

class_name Rat

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
@export var hole: StaticBody2D
@export var interaction_radius: int
var is_selected = false

var worker: Node2D
var assignee: Node2D

@export var health = 3

func _ready():
	$SFXManager.play("Squeak")
	target_closest_cargo()

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
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * SPEED
		_set_state(State.MOVING)
		$AnimatedSprite2D.play("move")
	else:
		_set_state(State.IDLE)
		$AnimatedSprite2D.play("idle")
	
	move_and_slide()

func _attack_state():
	$AnimationPlayer.play("eat")

func _death_state():
	if $AnimationPlayer.current_animation != "die":
		$AnimationPlayer.play("die")

func target_closest_cargo():
	for cargo in get_tree().get_nodes_in_group("cargo"):
		if not target:
			target = cargo
		elif global_position.distance_to(cargo.global_position) > global_position.distance_to(target.global_position):
			target = cargo

func _on_interactable_range_body_entered(body: Node2D) -> void:
	if body == target and state != State.DEAD:
		if target is Cargo:
			$CargoStealTimer.start()
			_set_state(State.ATTACKING)
		if target == hole:
			_deposit_loot()

func _on_interactable_range_body_exited(body: Node2D) -> void:
	if body == target and state != State.DEAD:
		$CargoStealTimer.stop()
		_set_state(State.IDLE)

func die():
	$CargoStealTimer.stop()
	for item in $LootSlot.get_children():
		if item is CargoItem:
			item.return_to_cargo()
	_set_state(State.DEAD)
	died.emit()

func _die():
	queue_free()
	
func on_hit():
	$SFXManager.play("Hit")
	health -= 1
	if health <= 0:
		die()

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
	if state != State.DEAD and not assignee:
		return true
	return false

func _on_cargo_steal_timer_timeout() -> void:
	if target is Cargo:
		var new_loot = target.move_item($LootSlot)
		if new_loot:
			new_loot.position = Vector2.ZERO
			$SFXManager.play("Squeak")
		target = hole
		_set_state(State.IDLE)

func _deposit_loot():
	for loot in $LootSlot.get_children():
		if loot is CargoItem:
			loot.die()
	target_closest_cargo()

func set_assignee(new_assignee: Crew) -> bool:
	if new_assignee and assignee:
		return false
	else:
		assignee = new_assignee
		return true

# This function is intended to be set when the respective crew is in range of the task to begin work
func set_worker(new_worker: Crew) -> bool:
	if not new_worker:
		set_assignee(new_worker)
	elif new_worker != assignee:
		return false
	worker = new_worker
	return true
