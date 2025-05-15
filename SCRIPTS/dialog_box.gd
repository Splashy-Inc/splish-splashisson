extends PanelContainer

class_name DialogBox

signal dialog_ended

@export var left_texture: Texture2D
@export var right_texture: Texture2D

# Left side is 0 - always the player, right side is 1
@export var speaker_sounds: Array[AudioStream]
@export var dialog_sound_players: Array[AudioStreamPlayer]

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
	
	for audio in speaker_sounds:
		for audio_player in dialog_sound_players:
			if audio_player.stream == null:
				audio_player.stream = audio
				break
	
	if dialog_data and dialog_data.dialog_text_json:
		_set_dialog_text(dialog_data.dialog_text_json.data["dialog_lines"][cur_dialog_position]["line"])
		dialog_sound_players[dialog_data.dialog_text_json.data["dialog_lines"][cur_dialog_position]["speaker"]].play()
	
	for button in end_buttons:
		button.reparent(dialog_button_section)
	_hide_end_buttons()
	
	

func _process(delta: float) -> void:
	pass

func advance_dialog():
	var next_line_data = _get_next_line()
	if next_line_data:
		_set_dialog_text(next_line_data["line"])
		dialog_sound_players[next_line_data["speaker"]].play()
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
	if button.action_type == DialogButton.Dialog_button_action_type.ADVANCE:
		advance_dialog()

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
	dialog_sound_players[0].play()
	if dialog_sound_players[0].playing:
		await dialog_sound_players[0].finished
	return true
