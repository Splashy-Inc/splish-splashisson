extends CanvasLayer

@export var hide_controls = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if hide_controls:
		$Controls.hide()
	else:
		$Controls.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
