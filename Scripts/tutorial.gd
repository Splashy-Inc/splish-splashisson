extends Level

class_name Tutorial

@export var dialog_files: Array[DialogData]

@onready var dialog_box: DialogBox = $HUD/DialogBox
@onready var hud: HUD = $HUD
@onready var movement_stage_area: Area2D = $DialogTriggers/MovementStage
@onready var crew_member: Crew = $People/CrewMember
@onready var splish: Player = $People/Splish
@onready var leak_spawn_point: Marker2D = $Obstacles/LeakSpawnPoint

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
	"Assign": {
		"objective": "Assign crew memeber to bail puddle (RIGHT-CLICK or B-BUTTON)"
	},
}

var stage := "Overview"

func _level_ready():
	crew_member.idle_distraction_timer.set_paused(true)
	splish.targeting_group_blacklist.append_array(["crew", "rowing_task", "leak", "puddle"])
	_show_next_dialog()

func _level_process(delta: float):
	match stage:
		"Select":
			if len(splish.followers) > 0:
				_show_next_dialog()

func _show_next_dialog():
	if not dialog_files.is_empty():
		player.process_mode = Node.PROCESS_MODE_DISABLED
		dialog_box.show()
		dialog_box.set_dialog_data(dialog_files.pop_front())
		stage = dialog_box.dialog_data.label
		
		if dialog_box.dialog_data.label in stages.keys():
			hud.set_objective(stages[dialog_box.dialog_data.label]["objective"])
		
		match dialog_box.dialog_data.label:
			"Select":
				splish.targeting_group_blacklist.erase("crew")
			"Assign":
				splish.targeting_group_blacklist.erase("leak")
				boat.spawn_leak(leak_spawn_point.global_position)

func _on_dialog_ended() -> void:
	player.process_mode = Node.PROCESS_MODE_INHERIT
	dialog_box.hide()
	if dialog_box.dialog_data.label == "Overview":
		await get_tree().create_timer(.5).timeout
		_show_next_dialog()

func _on_movement_stage_body_entered(body: Node2D) -> void:
	movement_stage_area.queue_free()
	_show_next_dialog()
