extends Button

class_name DialogButton

@export var action_type := Dialog_button_action_type.ADVANCE

enum Dialog_button_action_type {
	ADVANCE,
	CUSTOM
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
