extends Level

class_name Tutorial

@export var original_dialog_files: Array[DialogData]
var dialog_files: Array[DialogData]

@onready var level_ui: LevelUI = $LevelUI
@onready var movement_stage_area: Area2D = $DialogTriggers/MovementStage
@onready var crew_member: Crew = $People/CrewMember
@onready var splish: Player = $People/Splish
@onready var leak_spawn_point: Marker2D = $Obstacles/LeakSpawnPoint
@onready var puddle_spawn_point: Marker2D = $Obstacles/PuddleSpawnPoint
@onready var rat_hole: RatHole = $Obstacles/RatHole
@onready var leak_spawn_timer: Timer = $Obstacles/LeakSpawnTimer

var stages := {
	"Overview": {
		"objective": "None"
	},
	"Movement": {
		"objective": "Move to the yellow X on the bow (<movement>)"
	},
	"Select": {
		"objective": "Select a nearby crew member (<select>)"
	},
	"Assign": {
		"objective": "Assign crew member to patch the leak (<act>)"
	},
	"Act": {
		"objective": "Bail all puddles yourself (HOLD <act>)"
	},
	"Rats": {
		"objective": "Stomp the rat, or tell your crew to do it (<act>)"
	},
	"Rowing": {
		"objective": "Row 25% of the way to the end dock (<act>)"
	},
	"Distraction_1": {
		"objective": "Wait for crew member to get distracted"
	},
	"Distraction_2": {
		"objective": "Stop distracted crew from damaging cargo (<select>)"
	},
	"Wrap_up": {
		"objective": "Row the boat to the end dock"
	},
	"Complete": {
		"objective": "Tutorial done"
	},
}

var stage := "Overview"
var tutorial_leak: Leak
var tutorial_puddle: Puddle

func _level_ready():
	dialog_files = original_dialog_files.duplicate(true)
	crew_member.disable_morale = true
	crew_member.morale_bar.hide()
	rat_hole.spawn_timer.set_paused(true)
	leak_spawn_timer.set_paused(true)
	rat_hole.hide()
	splish.targeting_group_blacklist = ["crew", "leak", "puddle", "rat", "rowing_task"]
	movement_stage_area.hide()
	_show_next_dialog()

func _level_process(delta: float):
	match stage:
		"Select":
			if len(splish.followers) > 0:
				_show_next_dialog()
		"Assign":
			if not tutorial_puddle and tutorial_leak and tutorial_leak.current_puddle:
				tutorial_puddle = tutorial_leak.current_puddle
				tutorial_puddle.can_spread = false
		"Act":
			if len(puddle_spawn_point.get_children()) <= 0:
				_show_next_dialog()
		"Rowing":
			if progress >= length/4.0:
				_show_next_dialog()
		"Distraction_1":
			if crew_member.current_assignment != null:
				_show_next_dialog()
		"Distraction_2":
			if len(splish.followers) > 0:
				_show_next_dialog()
		"Wrap_up":
			if finished:
				_show_next_dialog()

func _show_next_dialog():
	if dialog_box and not dialog_files.is_empty():
		player.input_disabled = true
		dialog_box.show()
		dialog_box.set_dialog_data(dialog_files.pop_front())
		stage = dialog_box.dialog_data.label
		
		if dialog_box.dialog_data.label in stages.keys():
			level_ui.set_objective(Utils.replace_control_string_variables(stages[dialog_box.dialog_data.label]["objective"]))
		
		match dialog_box.dialog_data.label:
			"Movement":
				movement_stage_area.show()
			"Select":
				splish.targeting_group_blacklist.erase("crew")
			"Assign":
				splish.targeting_group_blacklist.erase("leak")
				var new_leak = boat.spawn_leak(leak_spawn_point.global_position)
				if new_leak and new_leak is Leak:
					new_leak.died.connect(_on_leak_patched)
					tutorial_leak = new_leak
			"Act":
				splish.targeting_group_blacklist.append("crew")
				splish.targeting_group_blacklist.erase("puddle")
				var new_puddle = boat.spawn_puddle(puddle_spawn_point.global_position)
				for puddle in get_tree().get_nodes_in_group("puddle"):
					puddle.reparent(puddle_spawn_point, true)
					if puddle != new_puddle and puddle is Puddle:
						while puddle.stage != Puddle.Stage.LARGE:
							puddle.increase_stage()
			"Rats":
				rat_hole.show()
				splish.targeting_group_blacklist.erase("crew")
				splish.targeting_group_blacklist.erase("rat")
				var new_rat = rat_hole.spawn_rat()
				if new_rat and new_rat is Rat:
					new_rat.died.connect(_on_rat_died)
			"Rowing":
				splish.targeting_group_blacklist.clear()
			"Distraction_1":
				boat.stern.reset_cargo()
				splish.targeting_group_blacklist.append_array(["crew", "rowing_task"])
				splish.set_assignment(null)
				crew_member.set_assignment(null)
				crew_member.change_morale(1.0)
				crew_member.morale_bar.show()
				splish.input_disabled = true
			"Distraction_2":
				splish.aura_visible = true
				splish.targeting_group_blacklist.clear()

func _on_dialog_ended() -> void:
	player.input_disabled = false
	dialog_box.hide()
	match dialog_box.dialog_data.label:
		"Overview":
			await get_tree().create_timer(.5).timeout
			_show_next_dialog()
		"Rowing":
			splish.add_follower(crew_member)
		"Distraction_1":
			crew_member.add_morale_modifier(load("res://Custom Resources/Morale Modifiers/tutorial_modifier.tres"))
			crew_member.disable_morale = false
		"Distraction_2":
			crew_member.remove_morale_modifier(load("res://Custom Resources/Morale Modifiers/tutorial_modifier.tres"))
		"Wrap_up":
			rat_hole.spawn_timer.set_paused(false)
			leak_spawn_timer.set_paused(false)
		"Complete":
			completed.emit()

func _on_movement_stage_body_entered(body: Node2D) -> void:
	movement_stage_area.queue_free()
	_show_next_dialog()

func _on_leak_patched():
	_show_next_dialog()

func _on_rat_died():
	_show_next_dialog()
