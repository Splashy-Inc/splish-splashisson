extends TabContainer

enum Tabs {
	KEYBOARD_AND_MOUSE,
	MOBILE,
	CONTROLLER,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("mobile"):
		current_tab = Tabs.MOBILE
	elif Globals.joypad_connected:
		current_tab = Tabs.CONTROLLER
	else:
		current_tab = Tabs.KEYBOARD_AND_MOUSE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		current_tab = Tabs.MOBILE
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		current_tab = Tabs.CONTROLLER
