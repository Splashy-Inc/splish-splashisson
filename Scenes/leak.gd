extends Task

var is_patched = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func patch():
	is_patched = true
	$AnimationTree.set("parameters/conditions/is_patched", true)
	set_worker(null)

func _die():
	queue_free()
