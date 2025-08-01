extends StaticBody2D

class_name Cargo

enum Cargo_type {
	NONE,
	MEAT,
	FUR,
}
@onready var items: Node2D = $Items

@export var cargo_item_scene: PackedScene

@export var cargo_type: Cargo_type
var num_items = 10
var item_health = 0
var item_texture: Texture2D
var max_condition = 0
var condition = 0
var threats = []

var level_complete = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.level_completed.connect(_on_level_completed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func initialize(new_type: Cargo_type, new_num_items: int):
	if not is_node_ready():
		await ready
	cargo_type = new_type
	num_items = 10
	await _spawn_cargo()
	_update_condition(max_condition)
	_set_item_info()

func _spawn_cargo():
	clear()
	if $StackArea/CollisionShape2D.shape is CircleShape2D:
		var spawn_origin = $StackArea/CollisionShape2D.global_position
		var spawn_radius = $StackArea/CollisionShape2D.shape.radius * global_scale.x
		for i in num_items:
			var spawn_point = _get_item_spawn_point(spawn_origin, spawn_radius)
			var new_cargo = cargo_item_scene.instantiate() as CargoItem
			new_cargo.initialize(self)
			items.add_child(new_cargo)
			new_cargo.died.connect(_cargo_item_died.bind(new_cargo))
			new_cargo.global_position = spawn_point
		if item_health <= 0:
			var item = items.get_children().front()
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
		if threats.is_empty() and item_health:
			var remainder = condition % item_health
			if remainder > 0:
				_update_condition(clamp(item_health - (condition % item_health), 0, item_health))
		else:
			_update_condition(-threats.size())

func _update_condition(change: int):
	condition = clamp(condition + change, 0, max_condition)
	var item_count_diff = clamp(items.get_child_count() - ceili(float(condition) / item_health), 0, num_items)
	for i in item_count_diff:
		get_item().die()
	Globals.update_cargo_condition(condition, max_condition)

func _set_item_info():
	Globals.update_cargo_items(num_items, item_health, item_texture)

func _on_level_completed(level: Level):
	level_complete = true
	$DamageTickTimer.stop()
	
func get_item():
	return items.get_children().front()

func add_item(item: CargoItem):
	if item:
		item.reparent(items, false)
		if item.cur_data.is_distraction:
			item.add_to_group("distraction")
		item.global_position = _get_item_spawn_point($StackArea/CollisionShape2D.global_position, $StackArea/CollisionShape2D.shape.radius)
		_update_condition(item_health)

func move_item(destination: Node2D):
	if destination:
		var item = get_item()
		if item:
			if destination != self:
				item.remove_from_group("distraction")
			item.reparent(destination)
			item.global_position = destination.global_position
			_update_condition(-item_health)
			return item
	return null

func _get_item_spawn_point(spawn_origin, spawn_radius):
	var spawn_point = spawn_origin + Vector2(randi_range(-spawn_radius, spawn_radius), randi_range(-spawn_radius, spawn_radius))
	while spawn_point.distance_to(spawn_origin) > spawn_radius * .9:
		spawn_point = spawn_origin + Vector2(randi_range(-spawn_radius, spawn_radius), randi_range(-spawn_radius, spawn_radius))
	return spawn_point

func clear():
	for item in items.get_children():
		item.queue_free()
