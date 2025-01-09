extends Area2D

class_name Cargo

enum Cargo_type {
	NONE,
	MEAT,
}

@export var meat_scene: PackedScene

@export var cargo_type: Cargo_type
var num_items = 10
var item_health = 0
var item_texture: CompressedTexture2D
var max_condition = 0
var condition = 0
var threats = []

var level_complete = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_cargo()
	_update_condition(max_condition)
	_set_item_info()
	Globals.level_completed.connect(_on_level_completed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _spawn_cargo():
	match cargo_type:
		Cargo_type.MEAT:
			if $StackArea/CollisionShape2D.shape is CircleShape2D:
				var spawn_origin = $StackArea/CollisionShape2D.global_position
				var spawn_radius = $StackArea/CollisionShape2D.shape.radius
				for i in num_items:
					var spawn_point = spawn_origin + Vector2(randi_range(-spawn_radius, spawn_radius), randi_range(-spawn_radius, spawn_radius))
					while spawn_point.distance_to(spawn_origin) > spawn_radius * .9:
						spawn_point = spawn_origin + Vector2(randi_range(-spawn_radius, spawn_radius), randi_range(-spawn_radius, spawn_radius))
					var new_cargo = meat_scene.instantiate()
					if item_health <= 0:
						item_health = new_cargo.health
						max_condition = num_items * item_health
						item_texture = new_cargo.get_sprite_texture()
					$Items.add_child(new_cargo)
					new_cargo.died.connect(_cargo_item_died.bind(new_cargo))
					new_cargo.global_position = spawn_point

func _cargo_item_died(item: CargoItem):
	print("Irreparable damage to cargo: ", item)

func add_threat(body: Node2D):
	if body is Puddle:
		body.died.connect(_on_threat_died.bind(body))
		body.large_reached.connect(_on_large_puddle_reached.bind(body))
		body.large_reversed.connect(_on_large_puddle_reversed.bind(body))

func _on_threat_died(threat: Node2D):
	if threat is Puddle:
		_on_large_puddle_reversed(threat)

func _on_large_puddle_reached(puddle: Puddle):
	threats.append(puddle)

func _on_large_puddle_reversed(puddle: Puddle):
	threats.erase(puddle)

func get_self_polygon():
	return Utils.shift_polygon($CollisionPolygon2D.polygon, global_position)

func _on_damage_tick_timer_timeout() -> void:
	if not level_complete:
		if threats.is_empty():
			var remainder = condition % item_health
			if remainder > 0:
				_update_condition(clamp(item_health - (condition % item_health), 0, item_health))
		else:
			_update_condition(-threats.size())

func _update_condition(change: int):
	if change < 0 and condition % item_health > 0 and condition % item_health <= abs(change):
		$Items.get_children().front().queue_free()
	condition = clamp(condition + change, 0, max_condition)
	Globals.update_cargo_condition(condition, max_condition)

func _set_item_info():
	Globals.update_cargo_items(num_items, item_health, item_texture)

func _on_level_completed():
	level_complete = true
	$DamageTickTimer.stop()
	
