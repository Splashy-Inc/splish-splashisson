extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shift_polygon(polygon: PackedVector2Array, point: Vector2):
	for i in polygon.size():
		polygon.set(i, polygon[i] + point)
	return polygon
