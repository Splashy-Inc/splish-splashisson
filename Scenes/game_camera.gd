extends Camera2D

@export var focus_target: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if focus_target:
		reparent.call_deferred(focus_target)
		global_position = focus_target.global_position
	else:
		print("Camera does not have a focus target! ", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
