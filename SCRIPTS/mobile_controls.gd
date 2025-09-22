extends Control

class_name MobileControls

@onready var joystick: JoyStick = $Joystick

@onready var act_button: TouchScreenButton = $ActButton
@onready var act_sprite: Sprite2D = $ActButton/Sprite2D

@onready var select_button: TouchScreenButton = $SelectButton
@onready var select_sprite: Sprite2D = $SelectButton/Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.is_mobile:
		joystick.show()
	else:
		joystick.hide()
	
	PlayerEvents.selection_target_updated.connect(_on_selection_target_updated)
	select_button.material.set_shader_parameter("line_color", Globals.crew_select_color)
	select_sprite.texture = null
	
	PlayerEvents.action_target_updated.connect(_on_action_target_updated)
	act_button.material.set_shader_parameter("line_color", Globals.action_color)
	act_sprite.texture = null

func _on_selection_target_updated(new_target: Node2D):
	select_button.material.set_shader_parameter("on", is_instance_valid(new_target) and not select_button.is_pressed())
	
	if is_instance_valid(new_target) and new_target.has_method("get_target_sprite"):
		select_sprite.texture = new_target.get_target_sprite()
	else:
		select_sprite.texture = null

func _on_action_target_updated(new_target: Node2D):
	act_button.material.set_shader_parameter("on", is_instance_valid(new_target) and not act_button.is_pressed())
	
	if is_instance_valid(new_target) and new_target.has_method("get_target_sprite"):
		act_sprite.texture = new_target.get_target_sprite()
	else:
		act_sprite.texture = null
