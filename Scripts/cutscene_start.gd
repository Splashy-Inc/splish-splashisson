extends Cutscene

@export var tutorial_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Override input for now since we want player to choose tutorial or skip
func _input(event: InputEvent) -> void:
	pass


func _on_tutorial_pressed() -> void:
	start_pressed.emit(tutorial_scene)
