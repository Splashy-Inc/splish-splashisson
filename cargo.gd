extends Area2D

class_name Cargo

enum Cargo_type {
	NONE,
	MEAT,
}

@export var meat_scene: PackedScene

@export var cargo_type: Cargo_type
var num_items = 10
var item_health = 30
var condition = num_items * item_health
var threats = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_cargo()

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
	if threats.is_empty():
		pass
	else:
		_update_condition(-threats.size())

func _update_condition(change: int):
	condition -= change
	Globals.update_cargo_condition(condition)
