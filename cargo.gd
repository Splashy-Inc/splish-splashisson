extends StaticBody2D

class_name Cargo

enum Cargo_type {
	NONE,
	MEAT,
}

@export var meat_scene: PackedScene

@export var cargo_type: Cargo_type
var num_items = 10
var condition = 100
var item_value = condition / num_items

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
					new_cargo.global_position = spawn_point
