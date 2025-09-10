extends PanelContainer

@export var condition_segment_scene: PackedScene
var condition_segments = []
@onready var condition_bar: HFlowContainer = $VBoxContainer/Cargo/ConditionBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_cargo_condition_updated(Globals.cargo_info["condition"], Globals.cargo_info["max_condition"])
	Globals.cargo_condition_updated.connect(_cargo_condition_updated)
	Globals.cargo_items_updated.connect(_cargo_items_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _cargo_condition_updated(max_condition: int, condition: int):
	for segment in condition_bar.get_children():
		segment.value = condition

func _set_up_cargo_info():
	for child in condition_bar.get_children():
		child.free()
	for i in Globals.cargo_info["max_items"]:
		var new_segment = condition_segment_scene.instantiate() as ConditionSegment
		new_segment.initialize(Globals.cargo_info["item_texture"], Globals.cargo_info["item_health"], i + 1)
		condition_bar.add_child(new_segment)
	condition_segments = condition_bar.get_children()

func _cargo_items_updated(cargo_info: Dictionary):
	_set_up_cargo_info()
