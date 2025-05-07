extends CanvasLayer

class_name LevelUI

@export var hide_objective = true

@onready var objective: HBoxContainer = $Objective
@onready var objective_label: Label = $"Objective/Objective Label"
@onready var mobile_controls: MobileControls = $MobileControls
@onready var pause_button: Button = $PauseButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	if hide_objective:
		objective.hide()
	else:
		objective.show()
	
	if not Globals.is_node_ready():
		await Globals.ready
	
	if Globals.is_mobile:
		mobile_controls.show()
		pause_button.show()
	else:
		mobile_controls.hide()
		pause_button.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_objective(new_objective_text: String):
	objective_label.text = new_objective_text
	hide_objective = false
	objective.show()
