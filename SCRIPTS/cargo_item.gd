extends Node2D

class_name CargoItem

@export var cargo_types: Array[CargoItemData]
@export var cur_data: CargoItemData

@onready var sprite: Sprite2D = $Sprite2D

var host_cargo: Cargo

signal died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize(cargo: Cargo):
	host_cargo = cargo
	if not is_node_ready():
		await ready
	for cargo_type_data in cargo_types:
		if cargo_type_data.type == host_cargo.cargo_type:
			cur_data = cargo_type_data
	
	if cur_data.is_distraction:
		add_to_group("distraction")
	
	sprite.texture = get_sprite_texture().duplicate()
	if sprite.texture is AnimatedTexture:
		sprite.texture.speed_scale = randf_range(.25, 2)

func die():
	died.emit()
	queue_free()

func get_sprite_texture():
	return cur_data.texture

func get_health():
	return cur_data.health

func get_type():
	return cur_data.type

func return_to_cargo():
	if host_cargo:
		host_cargo.add_item(self)
	else:
		print("No cargo to return to, make sure this was initialized properly: ", self)

func get_host():
	return host_cargo
