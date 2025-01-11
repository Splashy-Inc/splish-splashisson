extends CharacterBody2D

class_name Rat

const SPEED = 50.0

enum State {
	IDLE,
	MOVING,
	ATTACKING,
}

var state = State.IDLE

var target: Cargo
@export var hole: StaticBody2D

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

func _move_state(delta: float):
	if target:
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * SPEED
		state = State.MOVING
		$AnimatedSprite2D.play("move")
	else:
		state = State.IDLE
		$AnimatedSprite2D.play("idle")
	
	move_and_slide()

func _attack_state():
	$AnimatedSprite2D.play("eat")

func target_closest_cargo():
	for cargo in get_tree().get_nodes_in_group("cargo"):
		if not target:
			target = cargo
		elif global_position.distance_to(cargo.global_position) > global_position.distance_to(target.global_position):
			target = cargo

func _on_interactable_range_body_entered(body: Node2D) -> void:
	if body == target:
		target.add_threat(self)
		state = State.ATTACKING

func _on_interactable_range_body_exited(body: Node2D) -> void:
	if body == target:
		target.remove_threat(self)
		state = State.IDLE
