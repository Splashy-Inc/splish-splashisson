extends TextureProgressBar

class_name ConditionSegment

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize(texture: Texture2D, max_health: int, index: int):
	max_value = max_health * index
	min_value = max_value - max_health
	value = max_value
	set_texture(texture)

func set_texture(new_texture: Texture2D):
	texture_under = new_texture
	texture_progress = new_texture
