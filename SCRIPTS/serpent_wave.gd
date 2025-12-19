extends Area2D

class_name SerpentWave

var direction : Vector2
@export var speed := 100
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var animation_tree: AnimationTree = $AnimationPlayer/AnimationTree
var animation_sate_machine : AnimationNodeStateMachinePlayback

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_sate_machine = animation_tree.get("parameters/playback")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		sprite.flip_h = direction.x > 0
		global_position += direction * speed * delta
	
	if global_position.x < -300:
		queue_free()

func initialize(new_direction: Vector2, spawn: Vector2):
	direction = new_direction
	global_position = spawn
	animation_sate_machine.travel("start")

func _on_body_entered(body: Node2D) -> void:
	animation_sate_machine.travel("crash")

func crash():
	var puddle_spawn_point = global_position
	while not Globals.boat.is_point_in_boat(puddle_spawn_point) and abs(puddle_spawn_point.x) < 1000:
		puddle_spawn_point += direction
	Globals.boat.spawn_puddle(puddle_spawn_point, true)
	queue_free()
