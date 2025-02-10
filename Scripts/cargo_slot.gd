extends Node2D

class_name CargoSlot

var type: Cargo.Cargo_type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_cargo_type(new_type: Cargo.Cargo_type):
	if get_children().is_empty():
		type = new_type
		var new_cargo = Globals.generate_cargo()
		if new_cargo is Cargo:
			new_cargo.initialize(new_type, 10)
			clear()
			add_child(new_cargo)
			return true
		else:
			print("Type provided is not a cargo type, skipping this one and freeing orphan node: ", new_cargo)
			new_cargo.free()
			return false

func clear():
	for child in get_children():
		remove_child(child)
		child.queue_free()
