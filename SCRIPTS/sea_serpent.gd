extends Node2D

@export var path_follow_node : PathFollow2D
@export var target : Node2D
@export var flip := false

@export var speed := 200

@onready var animation_tree: AnimationTree = $AnimationPlayer/AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.get("parameters/playback").travel("Swim")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		flip = global_position.x < target.global_position.x
	
	if path_follow_node:
		path_follow_node.progress += speed * delta
