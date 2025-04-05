extends CanvasLayer

class_name HUD

@export var hide_controls = true
@export var hide_objective = true

@onready var controls: Label = $Controls
@onready var objective: HBoxContainer = $Objective
@onready var objective_label: Label = $"Objective/Objective Label"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if hide_controls:
		controls.hide()
	else:
		controls.show()
	
	if hide_objective:
		objective.hide()
	else:
		objective.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_objective(new_objective_text: String):
	objective_label.text = new_objective_text
	hide_objective = false
	objective.show()
