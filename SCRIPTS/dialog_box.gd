extends PanelContainer

class_name DialogBox

signal dialog_ended
signal skip_pressed

@export var left_texture: Texture2D
@export var right_texture: Texture2D

@export var left_sound: AudioStream
@export var right_sound: AudioStream
@export var left_sound_player: AudioStreamPlayer
@export var right_sound_player: AudioStreamPlayer

@export var dialog_data: DialogData
@export var end_buttons: Array[PackedScene]

@onready var left_texture_node: TextureRect = $HBoxContainer/LeftPanel/LeftTexture
@onready var right_texture_node: TextureRect = $HBoxContainer/RightPanel/RightTexture
@onready var dialog_text_node: Label = $HBoxContainer/TextArea/DialogTextSection/DialogText
@onready var dialog_button_section: HBoxContainer = $HBoxContainer/TextArea/DialogButtonSection
@onready var dialog_button: DialogButton = $HBoxContainer/TextArea/DialogButtonSection/DialogButton

var cur_dialog_position := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize()

func _process(delta: float) -> void:
	pass

func initialize():
	left_texture_node.texture = left_texture
	left_sound_player.stream = left_sound
	right_texture_node.texture = right_texture
	right_sound_player.stream = right_sound
	
	if dialog_data and dialog_data.dialog_text_json:
		_set_dialog_text(dialog_data.dialog_text_json.data["dialog_lines"][cur_dialog_position]["line"])
		match dialog_data.dialog_text_json.data["dialog_lines"][cur_dialog_position]["speaker"]:
			0:
				left_sound_player.play()
			1:
				right_sound_player.play()
	
	for button in end_buttons:
		button.reparent(dialog_button_section)
	_hide_end_buttons()

func advance_dialog():
	var next_line_data = _get_next_line()
	if next_line_data:
		_set_dialog_text(next_line_data["line"])
		var test = next_line_data["speaker"]
		match str(next_line_data["speaker"]):
			"0":
				left_sound_player.play()
			"1":
				right_sound_player.play()
	else:
		_show_end_buttons()

func _get_next_line():
	cur_dialog_position += 1
	if dialog_data.dialog_text_json:
		if cur_dialog_position < len(dialog_data.dialog_text_json.data["dialog_lines"]):
			return dialog_data.dialog_text_json.data["dialog_lines"][cur_dialog_position]
	return null

func _set_dialog_text(new_text: String):
	dialog_text_node.text = Utils.replace_control_string_variables(new_text)

func _on_dialog_button_pressed(button: DialogButton):
	match button.action_type:
		DialogButton.Dialog_button_action_type.ADVANCE:
			advance_dialog()
		DialogButton.Dialog_button_action_type.SKIP:
			skip_pressed.emit()

func _hide_end_buttons():
	for button in end_buttons:
		button.hide()
		dialog_button.show()

func _show_end_buttons():
	if end_buttons.is_empty():
		await play_confirmation_sound()
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

func _on_dialog_button_visibility_changed() -> void:
	update_view()

func update_view():
	if Globals.joypad_connected and visible:
		if not is_node_ready():
			await ready
		dialog_button.grab_focus()
		
func play_confirmation_sound():
	left_sound_player.play()
	if left_sound_player.playing:
		await left_sound_player.finished
	return true
