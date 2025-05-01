extends Sprite2D

@onready var parent: Node2D = $".."

var pressing = false

@export var maxLength = 64 
@export var deadzone = 5 

func _ready():
	maxLength *= parent.scale.x

func _process(delta):
	if pressing:
		if get_global_mouse_position().distance_to(parent.global_position) <= maxLength:
			global_position = get_global_mouse_position()
		else:
			var angle = parent.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = parent.global_position.x + cos(angle)*maxLength
			global_position.y = parent.global_position.y + sin(angle)*maxLength
		calculateVector()
	else:
		global_position = lerp(global_position, parent.global_position, delta*10)
		parent.direction = Vector2(0,0)

func calculateVector():
	if abs((global_position.x - parent.global_position.x)) >= deadzone:
		parent.direction.x = (global_position.x - parent.global_position.x)/maxLength
	if abs((global_position.y - parent.global_position.y)) >= deadzone:
		parent.direction.y = (global_position.y - parent.global_position.y)/maxLength
		
func _on_button_button_down() -> void:
	pressing = true

func _on_button_button_up() -> void:
	pressing = false
