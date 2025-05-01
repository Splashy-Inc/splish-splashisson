extends TabContainer

enum Tabs {
	KEYBOARD_AND_MOUSE,
	CONTROLLER,
	MOBILE,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_view()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_visibility_changed() -> void:
	update_view()

func update_view():
	if OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("mobile"):
		current_tab = Tabs.MOBILE
	elif Globals.joypad_connected:
		current_tab = Tabs.CONTROLLER
		if visible:
			get_tab_bar().grab_focus()
	else:
		current_tab = Tabs.KEYBOARD_AND_MOUSE
