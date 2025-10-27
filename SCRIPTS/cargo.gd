extends Task

class_name Cargo

enum Cargo_type {
	NONE,
	MEAT,
	FUR,
	VALUABLES,
	LIVESTOCK,
	MEDICINE,
	WEAPONS,
	MEAD,
	SIREN,
}
@onready var items: Node2D = $Items

@export var cargo_item_scene: PackedScene

@export var cargo_data: CargoItemData
var num_items = 10
var item_health = 0
var item_texture: Texture2D
var max_condition = 0
var condition = 0
var threats = []

var level_complete = false

func initialize(new_data: CargoItemData):
	if not is_node_ready():
		await ready
	
	cargo_data = new_data
	if cargo_data.type == Cargo_type.LIVESTOCK:
		collision_layer += 2 # Add to interactable collision layer
	
	num_items = new_data.number_items
	await _spawn_cargo()
	_update_condition(max_condition)
	
	sprite.texture = new_data.container_texture
	CargoEvents.cargo_changed.emit(self)

func _spawn_cargo():
	clear()
	if $StackArea/CollisionShape2D.shape is CircleShape2D:
		var spawn_origin = $StackArea/CollisionShape2D.global_position
		var spawn_radius = $StackArea/CollisionShape2D.shape.radius * global_scale.x
		for i in num_items:
			var spawn_point = _get_item_spawn_point(spawn_origin, spawn_radius)
			var new_cargo = Globals.generate_cargo_item(cargo_data.type)
			new_cargo.initialize(self)
			items.add_child(new_cargo)
			new_cargo.died.connect(_cargo_item_died.bind(new_cargo))
			new_cargo.health_changed.connect(_on_cargo_item_health_changed)
			new_cargo.global_position = spawn_point
		if item_health <= 0 and not get_cargo_items().is_empty():
			var item = get_cargo_items().front()
			item_health = item.get_health()
			max_condition = num_items * item_health
			item_texture = item.get_sprite_texture()

func _cargo_item_died(item: CargoItem):
	print("Irreparable damage to cargo: ", item)

func add_threat(body: Node2D):
	if body is Puddle:
		body.died.connect(_on_threat_died.bind(body))
		body.large_reached.connect(_on_large_puddle_reached.bind(body))
		body.large_reversed.connect(_on_large_puddle_reversed.bind(body))
		return true
	else:
		threats.append(body)
		return true
	return false
	
func remove_threat(body: Node2D):
	threats.erase(body)
	return true

func _on_threat_died(threat: Node2D):
	if threat is Puddle:
		_on_large_puddle_reversed(threat)

func _on_large_puddle_reached(puddle: Puddle):
	threats.append(puddle)

func _on_large_puddle_reversed(puddle: Puddle):
	remove_threat(puddle)

func get_self_polygon():
	return Utils.shift_polygon($CollisionPolygon2D.polygon, global_position)

func _on_damage_tick_timer_timeout() -> void:
	if not level_complete:
		if threats.is_empty():
			if cargo_data.type != Cargo_type.LIVESTOCK:
				repair_item()
		else:
			_update_condition(-threats.size())

func repair_item():
	var item_to_repair := get_most_damaged_item()
	if item_to_repair:
		item_to_repair.restore_health()

func _update_condition(change: int):
	# Update the most damaged item
	var item_to_update := get_most_damaged_item()
	if not item_to_update:
		return false
	
	if change > 0:
		if item_to_update.health == item_to_update.max_health:
			return false
		if change > item_to_update.max_health - item_to_update.health:
			change -= item_to_update.max_health - item_to_update.health
			item_to_update.restore_health()
			_update_condition(change)
		else:
			item_to_update.change_health(change)
	elif change < 0:
		if item_to_update.health == 0:
			return false
		if abs(change) > item_to_update.health:
			change += item_to_update.health
			item_to_update.change_health(-item_to_update.health)
			_update_condition(change)
		else:
			item_to_update.change_health(change)
	
	condition = get_total_items_health()
	
	CargoEvents.condition_updated.emit(condition, max_condition)
	return true

func _on_hit(change: int, distributed: bool = false):
	if distributed and change != 0 and not get_cargo_items().is_empty():
		var distributed_change = change/get_cargo_items().size()
		for item in get_cargo_items():
			item.change_health(distributed_change)
	else:
		_update_condition(change)

func get_total_items_health():
	var total_health = 0
	for item in get_cargo_items():
		if item is CargoItem:
			if item.get_type() == Cargo_type.LIVESTOCK:
				total_health += item.max_health
			else:
				total_health += item.health
	return total_health

func get_most_damaged_item() -> CargoItem:
	var most_damaged_item: CargoItem
	for item in get_cargo_items():
		if item is CargoItem:
			if not most_damaged_item or item.get_health() <= most_damaged_item.get_health():
				most_damaged_item = item
	
	return most_damaged_item

func _on_cargo_item_health_changed(new_health: int):
	condition = get_total_items_health()

func get_cargo_items() -> Array[CargoItem]:
	var items_array: Array[CargoItem]
	for item in items.get_children():
		if item is CargoItem:
			items_array.append(item)
	return items_array

func _on_level_completed(level: Level):
	level_complete = true
	$DamageTickTimer.stop()
	for item in get_cargo_items():
		item.degrade_tick_timer.stop()
	
func get_item() -> CargoItem:
	return get_cargo_items().front()

func add_item(item: CargoItem):
	if item:
		item.reparent(items, false)
		if item.cur_data.is_distraction:
			item.add_to_group("distraction")
		item.global_position = _get_item_spawn_point($StackArea/CollisionShape2D.global_position, $StackArea/CollisionShape2D.shape.radius)

func move_item(destination: Node2D):
	if destination:
		var item = get_item()
		if item:
			if destination != self:
				item.remove_from_group("distraction")
			item.reparent(destination)
			item.global_position = destination.global_position
			return item
	return null

func _get_item_spawn_point(spawn_origin, spawn_radius):
	var spawn_point = spawn_origin + Vector2(randi_range(-spawn_radius, spawn_radius), randi_range(-spawn_radius, spawn_radius))
	while spawn_point.distance_to(spawn_origin) > spawn_radius * .9:
		spawn_point = spawn_origin + Vector2(randi_range(-spawn_radius, spawn_radius), randi_range(-spawn_radius, spawn_radius))
	return spawn_point

func clear():
	for item in get_cargo_items():
		item.queue_free()

func is_targetable():
	return cargo_data.type == Cargo_type.LIVESTOCK and condition > 0

# Override assignee and worker setters since we want multiple to be able to work on a cargo at a time
func set_assignee(new_assignee: Worker) -> bool:
	return condition > 0

func set_worker(new_worker: Worker) -> bool:
	return condition > 0

func get_type() -> Cargo.Cargo_type:
	return cargo_data.type
