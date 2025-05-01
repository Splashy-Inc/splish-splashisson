extends Node2D

class_name JoyStick

# If you want to have a joystick to use as input around, just reference Globals.joystick.direction 
#    to get the non-normalized direction vector
var direction:Vector2

func _ready() -> void:
	Globals.joystick = self
