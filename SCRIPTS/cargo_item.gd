extends Node2D

class_name CargoItem

signal died
signal health_changed(new_health: int)

@export var cur_data: CargoItemData

@onready var degrade_tick_timer: Timer = $DegradeTickTimer
@export var sprite: Node2D

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
	if is_instance_valid(host_cargo) and host_cargo.is_connected("threats_changed", _on_host_threats_changed):
		host_cargo.disconnect("threats_changed", _on_host_threats_changed)
	host_cargo = cargo
	host_cargo.connect("threats_changed", _on_host_threats_changed)
	if not is_node_ready():
		await ready
	
	cur_data = host_cargo.cargo_data
	
	max_health = cur_data.health
	health = cur_data.health
	
	if cur_data.is_distraction:
		add_to_group("distraction")
	
	set_sprite_texture(cur_data.texture.duplicate())
	
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

func set_sprite_texture(new_texture):
	sprite.texture = new_texture
	if sprite.texture is AnimatedTexture:
		sprite.texture.speed_scale = randf_range(.25, 2)

func _on_host_threats_changed(threats: Array):
	pass
