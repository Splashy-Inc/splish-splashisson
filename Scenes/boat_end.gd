extends StaticBody2D

# TODO: Make this all work with cargo class once that is created
@export var cargo: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_cargo(cargo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_cargo(new_cargo):
	clear_cargo()
	if $CargoSlot.get_children().is_empty():
		cargo = new_cargo
		$CargoSlot.add_child(cargo)
		print("New cargo for ", self, ": ", cargo)

func clear_cargo():
	for cur_cargo in $CargoSlot.get_children():
		$CargoSlot.remove_child(cur_cargo)
	cargo = null
