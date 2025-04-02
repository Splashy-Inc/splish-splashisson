extends Level

@export var dialog_files: Array[DialogData]

@onready var dialog_box: DialogBox = $HUD/DialogBox
@onready var hud: HUD = $HUD
@onready var movement_stage_area: Area2D = $DialogTriggers/MovementStage

var stages := {
	"Overview": {
		"objective": "None"
	},
	"Movement": {
		"objective": "Move to the bow (WASD or LEFT-STICK)"
	},
	"Select": {
		"objective": "Select a nearby crew member (LEFT-CLICK or A-BUTTON)"
	},
}

func _level_ready():
	_show_next_dialog()

func _show_next_dialog():
	if not dialog_files.is_empty():
		player.process_mode = Node.PROCESS_MODE_DISABLED
		dialog_box.show()
		dialog_box.set_dialog_data(dialog_files.pop_front())
		if dialog_box.dialog_data.label in stages.keys():
			hud.set_objective(stages[dialog_box.dialog_data.label]["objective"])

func _on_dialog_ended() -> void:
	player.process_mode = Node.PROCESS_MODE_INHERIT
	dialog_box.hide()
	if dialog_box.dialog_data.label == "Overview":
		await get_tree().create_timer(.5).timeout
		_show_next_dialog()

func _on_movement_stage_body_entered(body: Node2D) -> void:
	movement_stage_area.queue_free()
	_show_next_dialog()
