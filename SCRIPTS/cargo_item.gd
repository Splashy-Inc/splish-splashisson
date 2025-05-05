extends Node2D

class_name CargoItem

@export var health: int
var host_cargo: Cargo

signal died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize(cargo: Cargo):
	host_cargo = cargo

func die():
	died.emit()
	queue_free()

func get_sprite_texture():
	return $Sprite2D.texture

func return_to_cargo():
	if host_cargo:
		host_cargo.add_item(self)
	else:
		print("No cargo to return to, make sure this was initialized properly: ", self)
