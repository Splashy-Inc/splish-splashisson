extends PanelContainer

class_name DialogBox

signal dialog_ended

@export var left_texture: Texture2D
@export var right_texture: Texture2D
@export var dialog_data: DialogData
@export var end_buttons: Array[DialogButton]

@onready var left_texture_node: TextureRect = $HBoxContainer/LeftPanel/LeftTexture
@onready var right_texture_node: TextureRect = $HBoxContainer/RightPanel/RightTexture
@onready var dialog_text_node: Label = $HBoxContainer/TextArea/DialogTextSection/DialogText
@onready var dialog_button_section: HBoxContainer = $HBoxContainer/TextArea/DialogButtonSection
@onready var dialog_button: DialogButton = $HBoxContainer/TextArea/DialogButtonSection/DialogButton

var cur_dialog_position := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	left_texture_node.texture = left_texture
	right_texture_node.texture = right_texture
		
	if dialog_data and not dialog_data.dialog_text.is_empty():
		_set_dialog_text(dialog_data.dialog_text[cur_dialog_position])
	
	for button in end_buttons:
		button.reparent(dialog_button_section)
	_hide_end_buttons()

func _process(delta: float) -> void:
	if Globals.joypad_connected and dialog_button.visible and not dialog_button.has_focus():
		dialog_button.grab_focus()

func advance_dialog():
	var next_line = _get_next_line()
	if next_line:
		_set_dialog_text(next_line)
	else:
		_show_end_buttons()

func _get_next_line():
	cur_dialog_position += 1
	if cur_dialog_position < len(dialog_data.dialog_text):
		return dialog_data.dialog_text[cur_dialog_position]
	return null

func _set_dialog_text(new_text: String):
	dialog_text_node.text = new_text

func _on_dialog_button_pressed(button: DialogButton):
	if button.action_type == DialogButton.Dialog_button_action_type.ADVANCE:
		advance_dialog()

func _hide_end_buttons():
	for button in end_buttons:
		button.hide()
		dialog_button.show()

func _show_end_buttons():
	if end_buttons.is_empty():
		dialog_ended.emit()
	else:
		dialog_button.hide()
		for button in end_buttons:
			button.show()
		end_buttons.front().grab_focus()
			
func set_dialog_data(new_dialog_data: DialogData):
	dialog_data = new_dialog_data
	cur_dialog_position = -1
	advance_dialog()
