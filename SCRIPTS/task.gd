extends StaticBody2D

class_name Task

var assignee: Worker
var worker: Worker
@export var morale_modifier := preload("res://Custom Resources/Morale Modifiers/task_morale_modifier.tres")

var is_active = false

var is_selected = false
@export var interaction_radius: int

var level_completed = false

@export var dismount_point : Marker2D
@export var self_space : CollisionPolygon2D

func _ready():
	Globals.level_completed.connect(_on_level_completed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_assignee(new_assignee: Worker) -> bool:
	if new_assignee and assignee:
		return false
	else:
		assignee = new_assignee
		return true

func set_worker(new_worker: Worker):
	return _set_worker(new_worker)

# This function is intended to be set when the respective worker is in range of the task to begin work
func _set_worker(new_worker: Worker) -> bool:
	if not new_worker:
		set_assignee(new_worker)
		if worker: # Null being passed in means removing current worker, so show them
			worker.show_self()
			toggle_active(false)
	elif new_worker == assignee: # Only allow setting worker if not already taken
		if worker == null:
			new_worker.hide_self()
			if not new_worker is Player:
				if is_instance_valid(dismount_point):
					new_worker.global_position = dismount_point.global_position
				else:
					new_worker.global_position = global_position
			toggle_active(true)
		else:
			return false
	
	worker = new_worker
	return true

func play_animation(animation_name):
	$AnimatedSprite2D.play(animation_name)
	
func set_highlight(is_enable: bool):
	is_selected = is_enable
	if $AnimatedSprite2D.material:
		$AnimatedSprite2D.material.set_shader_parameter("on", is_enable)
	else:
		print(self, " has no highlight material to activate.")

func toggle_active(set_active: bool):
	is_active = set_active
	if is_active:
		if assignee is Player:
			play_animation("active_player")
		else:
			play_animation("active")
	else:
		play_animation("idle")

func get_self_polygon():
	if is_instance_valid(self_space):
		return Utils.shift_polygon(self_space.polygon, global_position)
	return null
	
func _on_level_completed(level: Level):
	level_completed = true
	stop()

func stop():
	pass

func get_morale_modifier() -> MoraleModifier:
	if is_instance_valid(morale_modifier):
		return morale_modifier
	return MoraleModifier.new()
