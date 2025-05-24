extends StaticBody2D

class_name BoatEnd

signal cargo_set_up

@onready var play_grid: PlayGrid = $PlayGrid

var cargo_type: Cargo.Cargo_type
var cargo_slots: Array[CargoSlot]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if cargo_type != Cargo.Cargo_type.NONE:
		call_deferred("_set_up_cargo")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_up_cargo():
	cargo_slots = play_grid.get_cargo_slots()
	
	clear_cargo()
	# Generate and place new cargo
	for slot in cargo_slots:
		if slot.set_cargo_type(cargo_type):
			break
	
	cargo_set_up.emit()

func set_cargo(new_cargo_type: Cargo.Cargo_type):
	cargo_type = new_cargo_type
	call_deferred("_set_up_cargo")

func clear_cargo():
	for slot in cargo_slots:
		if slot:
			slot.clear()

func is_point_in_play_space(point: Vector2):
	return Geometry2D.is_point_in_polygon(point-$PlaySpace/CollisionPolygon2D.global_position, $PlaySpace/CollisionPolygon2D.polygon)

func get_play_grid_origin():
	return play_grid.global_position
