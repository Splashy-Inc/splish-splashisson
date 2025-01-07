extends Node2D

class_name CargoItem

@export var health: int

signal died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func die():
	died.emit()
	queue_free()

func get_sprite_texture():
	return $Sprite2D.texture
