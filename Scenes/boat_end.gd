extends StaticBody2D

# TODO: Make this all work with cargo class once that is created
@export var cargo: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if cargo:
		set_cargo(cargo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_cargo(updated_cargo):
	clear_cargo()
	if $CargoSlot.get_children().is_empty():
		cargo = updated_cargo
		var new_cargo = cargo.instantiate()
		$CargoSlot.add_child(new_cargo)
		print("New cargo for ", self, ": ", cargo)

func clear_cargo():
	for cur_cargo in $CargoSlot.get_children():
		$CargoSlot.remove_child(cur_cargo)
	cargo = null

func is_point_in_play_space(point: Vector2):
	return Geometry2D.is_point_in_polygon(point-$PlaySpace/CollisionPolygon2D.global_position, $PlaySpace/CollisionPolygon2D.polygon)
