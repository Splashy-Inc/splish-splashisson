extends Creature

class_name Rat

@export var hole: StaticBody2D
@export var loot_slot : Marker2D
@export var cargo_timer : Timer

func _on_interactable_range_body_entered(body: Node2D) -> void:
	if body == target and state != State.DEAD:
		if target is Cargo:
			cargo_timer.start()
			_set_state(State.ATTACKING)
		if target == hole:
			_deposit_loot()

func _on_interactable_range_body_exited(body: Node2D) -> void:
	if body == target and state != State.DEAD:
		if target is Cargo:
			cargo_timer.stop()
		_set_state(State.IDLE)

func _on_cargo_steal_timer_timeout() -> void:
	if target is Cargo:
		var new_loot = target.move_item(loot_slot)
		if new_loot:
			new_loot.position = Vector2.ZERO
			sfx_manager.play("SpawnNoise")
		target = hole
		_set_state(State.IDLE)

func _deposit_loot():
	for loot in loot_slot.get_children():
		if loot is CargoItem:
			loot.die()
	target_closest_cargo()

func die():
	cargo_timer.stop()
	for item in loot_slot.get_children():
		if item is CargoItem:
			item.return_to_cargo()
	set_highlight(true, defeated_color)
	_set_state(State.DEAD)
	collision_shape.disabled = true
	died.emit()
