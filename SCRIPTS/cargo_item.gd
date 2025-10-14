extends Node2D

class_name CargoItem

signal died
signal health_changed(new_health: int)

@export var cargo_types: Array[CargoItemData]
@export var cur_data: CargoItemData

@onready var degrade_tick_timer: Timer = $DegradeTickTimer
@onready var sprite: Sprite2D = $Sprite2D

var type: Cargo.Cargo_type

var host_cargo: Cargo
var max_health: int
var health: int

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
	
	max_health = cur_data.health
	health = cur_data.health
	
	if cur_data.is_distraction:
		add_to_group("distraction")
	
	sprite.texture = cur_data.texture.duplicate()
	if sprite.texture is AnimatedTexture:
		sprite.texture.speed_scale = randf_range(.25, 2)
	
	if cur_data.type == Cargo.Cargo_type.LIVESTOCK:
		degrade_tick_timer.start()
	else:
		degrade_tick_timer.stop()

func die():
	set_health(0)
	died.emit()
	queue_free()

func get_sprite_texture():
	return sprite.texture

func get_max_health():
	return max_health

func get_type():
	return cur_data.type

func return_to_cargo():
	if host_cargo:
		host_cargo.add_item(self)
	else:
		print("No cargo to return to, make sure this was initialized properly: ", self)

func get_host():
	return host_cargo

func get_health():
	return health

func change_health(change: int):
	health = clamp(health + change, 0, max_health)
	health_changed.emit(health)
	if health <= 0:
		die()

func set_health(new_health: int):
	health = new_health
	health_changed.emit(health)

func restore_health():
	change_health(max_health)

func _on_degrade_tick_timer_timeout() -> void:
	change_health(-1)
