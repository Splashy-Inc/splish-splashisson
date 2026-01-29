extends Label

class_name StageLabel

@export var button : LevelButton
@export var highlights : Array[StageLabel]

const NORMAL_COLOR = Color("93845b")
const HIGHLIGHT_COLOR = Color("ffbd32")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_instance_valid(button):
		button.mouse_entered.connect(_on_button_mouse_entered)
		button.mouse_exited.connect(_on_button_mouse_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_mouse_entered():
	for node in get_tree().get_nodes_in_group("stage_label"):
		node.hide()
		if node is StageLabel:
			node.set("theme_override_colors/font_color", NORMAL_COLOR)
	
	for node in highlights:
		node.show()
	
	set("theme_override_colors/font_color", HIGHLIGHT_COLOR)

func _on_button_mouse_exited():
	set("theme_override_colors/font_color", NORMAL_COLOR)
