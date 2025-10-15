extends PanelContainer

@export var condition_segment_scene: PackedScene
var condition_segments = []
@onready var condition_bar: HFlowContainer = $VBoxContainer/Cargo/ConditionBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CargoEvents.cargo_changed.connect(_cargo_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_up_cargo_info(new_cargo: Cargo):
	for child in condition_bar.get_children():
		child.free()
	for item in new_cargo.get_cargo_items():
		var new_segment = condition_segment_scene.instantiate() as ConditionSegment
		new_segment.initialize(item)
		condition_bar.add_child(new_segment)
	condition_segments = condition_bar.get_children()

func _cargo_updated(new_cargo: Cargo):
	_set_up_cargo_info(new_cargo)
