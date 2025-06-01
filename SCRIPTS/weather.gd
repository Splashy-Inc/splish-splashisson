extends CanvasLayer

class_name Weather

signal rain_ticked

enum Type {
	NONE,
	STORM,
}

@export var type: Type

@onready var storm: Node2D = $Storm
@onready var rain_timer: Timer = $Storm/RainTimer
@onready var lightning_timer: Timer = $Storm/LightningTimer
@onready var lightning_animation_player: AnimationPlayer = $Storm/Lightning/AnimationPlayer

const LIGHTNING_MAX_TIME := 8

func _ready() -> void:
	set_type(type)

func set_type(new_type: Type):
	type = new_type
	_update_type()
	
func _update_type():
	stop_effects()
	match type:
		Type.STORM:
			rain_timer.start()
			lightning_timer.start()
			storm.show()

func stop_effects():
	rain_timer.stop()
	storm.hide()

func _on_rain_timer_timeout() -> void:
	rain_ticked.emit()

func _on_lightning_timer_timeout() -> void:
	lightning_timer.start(randi_range(3, LIGHTNING_MAX_TIME))
	lightning_animation_player.play("flash")
