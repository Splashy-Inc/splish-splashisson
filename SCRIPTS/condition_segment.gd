extends TextureProgressBar

class_name ConditionSegment

@export var cargo_item: CargoItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_instance_valid(cargo_item):
		initialize(cargo_item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize(new_cargo_item: CargoItem):
	cargo_item = new_cargo_item
	cargo_item.health_changed.connect(_on_item_health_changed)
	max_value = cargo_item.max_health
	min_value = max_value - cargo_item.max_health
	value = max_value
	set_texture(cargo_item.cur_data.texture.duplicate())

func set_texture(new_texture: Texture2D):
	if new_texture is AnimatedTexture:
		texture_under = new_texture.get_frame_texture(0).duplicate()
		texture_progress = new_texture.get_frame_texture(0).duplicate()
	else:
		texture_under = new_texture
		texture_progress = new_texture

func _on_item_health_changed(new_health: int):
	value = new_health
