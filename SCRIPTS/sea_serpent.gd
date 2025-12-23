extends Node2D

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_machine = animation_tree.get("parameters/playback")
	state_machine.travel("Swim")

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
					if target is RowingTask and abs(global_position.y - target.global_position.y) < 4:
						global_position.y = target.global_position.y + 24
						state_machine.travel("Chomp")
						current_action = Actions.CHOMP
				Actions.CHOMP:
					if target is RowingTask and abs(global_position.y - target.global_position.y) < 4:
						global_position.y = target.global_position.y + 24
						state_machine.travel("Jump")
						current_action = Actions.JUMP
				Actions.JUMP:
					path_follow_node.progress_ratio = .12
					state_machine.travel("Swim")
					current_action = Actions.SWIM
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
			if path_follow_node:
				if path_follow_node.progress_ratio > 0 and path_follow_node.progress_ratio < .05:
					state_machine.travel("Hidden")
					target = get_tree().get_nodes_in_group("rowing_task").pick_random()
					return
				
				path_follow_node.progress += speed * delta
				
				spawn_wave(global_position)

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
