extends Node2D

@export var path_follow_node : PathFollow2D
@export var target : Node2D
@export var flip := false

@export var speed := 200

@onready var animation_tree: AnimationTree = $AnimationPlayer/AnimationTree
var state_machine : AnimationNodeStateMachinePlayback

enum Actions {
	SWIM,
	CHOMP,
	JUMP,
}

var current_action := Actions.SWIM

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
				path_follow_node.progress += speed * delta
