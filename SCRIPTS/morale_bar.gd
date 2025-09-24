extends ProgressBar

var color_gradient := preload("res://Materials/morale_gradient.tres")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self_modulate = color_gradient.gradient.sample(value/max_value)
