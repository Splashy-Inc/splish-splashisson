extends Node2D

class_name SeaSerpent

@export var path_follow_node : PathFollow2D
@export var target : Node2D
@export var flip := false

@export var speed := 200

@export var wave_scene : PackedScene

@onready var animation_tree: AnimationTree = $AnimationPlayer/AnimationTree
var state_machine : AnimationNodeStateMachinePlayback

enum Actions {
	SWIM,
	CHOMP,
	JUMP,
}

var current_action := Actions.SWIM

var last_wave_spawn : Vector2

const CHOMPS_PER_ACTION = 3
var remaining_chomps := CHOMPS_PER_ACTION

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine = animation_tree.get("parameters/playback")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		flip = global_position.x < target.global_position.x
	
	match state_machine.get_current_node():
		"Hidden":
			if path_follow_node:
				path_follow_node.progress += speed * delta * 2
			
			match current_action:
				Actions.SWIM:
					remaining_chomps = CHOMPS_PER_ACTION
					start_chomp()
				Actions.CHOMP:
					if remaining_chomps > 0:
						start_chomp()
					else:
						start_jump()
				Actions.JUMP:
					start_swim()
		"Chomp":
			pass
		"Idle":
			state_machine.travel("Hidden")
		"Jump":
			pass
		"Rise":
			pass
		"Sink":
			pass
		"Swim":
			if target == null:
				target = Globals.boat
			
			if path_follow_node:
				if path_follow_node.progress_ratio > 0 and path_follow_node.progress_ratio < .05:
					state_machine.travel("Hidden")
					return
				
				path_follow_node.progress += speed * delta
				
				spawn_wave(global_position)

func initialize(new_path_follow_node: PathFollow2D):
	path_follow_node = new_path_follow_node
	path_follow_node.add_child(self)
	start_swim()

func spawn_wave(spawn_point: Vector2):
	if abs(spawn_point.y - last_wave_spawn.y) >= 32:
		var new_wave = wave_scene.instantiate() as SerpentWave
		Globals.boat.add_child(new_wave)
		if not flip:
			new_wave.initialize(Vector2.LEFT, spawn_point)
		else:
			new_wave.initialize(Vector2.RIGHT, spawn_point)
		new_wave.scale = Vector2.ONE
		last_wave_spawn = spawn_point

func spawn_puddle_strip():
	if is_instance_valid(Globals.boat):
		for cell_center in Globals.boat.get_horizontal_cell_centers(global_position.y):
			Globals.boat.spawn_puddle(cell_center, true)

func start_swim():
	position = Vector2.ZERO
	path_follow_node.progress_ratio = .12
	state_machine.travel("Swim")
	current_action = Actions.SWIM

func start_chomp():
	var valid_targets : Array[RowingTask]
	for rowing_task in get_tree().get_nodes_in_group("rowing_task"):
		if rowing_task is RowingTask and is_instance_valid(rowing_task.worker):
			valid_targets.append(rowing_task)
	
	if valid_targets.is_empty():
		remaining_chomps = 0
	else:
		remaining_chomps -= 1
		target = valid_targets.pick_random()
		if target.global_position.x > Globals.boat.global_position.x:
			global_position.x = Globals.boat.global_position.x + 320
		else:
			global_position.x = Globals.boat.global_position.x - 320
		global_position.y = target.global_position.y + 24
		state_machine.travel("Chomp")
	
	current_action = Actions.CHOMP

func chomp_target():
	if target is RowingTask:
		if is_instance_valid(target.worker):
			target.worker.set_assignment(null)

func start_jump():
	target = get_tree().get_nodes_in_group("rowing_task").pick_random()
	if target is RowingTask:
		global_position.y = target.global_position.y + 24
		state_machine.travel("Jump")
		current_action = Actions.JUMP
