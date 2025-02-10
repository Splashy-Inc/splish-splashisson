extends StaticBody2D

signal cargo_set_up

@export var cargo_list: Array[Cargo.Cargo_type]
var cargo_slots: Array[CargoSlot]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_set_up_cargo")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_up_cargo():
	cargo_slots = $PlayGrid.get_cargo_slots()
	
	clear_cargo()
	# Generate and place new cargo
	for cargo_type in cargo_list:
		for slot in cargo_slots:
			if slot.set_cargo_type(cargo_type):
				cargo_type = Cargo.Cargo_type.NONE
				break
		if cargo_type != Cargo.Cargo_type.NONE:
			print("Unable to assign ", Cargo.Cargo_type.keys()[cargo_type], " to a slot. There may not be enough slots.")
	
	cargo_set_up.emit()

func set_cargo(new_cargo_list: Array[Cargo.Cargo_type]):
	cargo_list = new_cargo_list
	_set_up_cargo()

func clear_cargo():
	for slot in cargo_slots:
		if slot is CargoSlot:
			slot.clear()

func is_point_in_play_space(point: Vector2):
	return Geometry2D.is_point_in_polygon(point-$PlaySpace/CollisionPolygon2D.global_position, $PlaySpace/CollisionPolygon2D.polygon)

func get_play_grid_origin():
	return $PlayGrid.global_position
