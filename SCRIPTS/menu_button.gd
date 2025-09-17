extends Button

class_name CustomMenuButton

enum Type {
	NONE,
	MAIN_MENU,
	PLAY,
	LEVEL,
	NEXT,
	RESTART,
	CONTROLS,
	QUIT,
}

@export var type := Type.NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
