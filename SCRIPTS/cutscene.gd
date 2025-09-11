extends Node

class_name Cutscene

signal start_pressed
signal skip_pressed

@export var stage_data := StageData.new()

@export var boat_length := 0
@export var deck_tasks : Array[Globals.Task_type]

@export var dialog_box : DialogBox
@export var weather : Weather
@export var boat : Boat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_stage_data(stage_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_stage_data(new_stage_data: StageData):
	weather.set_type(new_stage_data.weather)
	
	boat_length = new_stage_data.boat_length
	deck_tasks = new_stage_data.boat_task_list
	boat.initialize(boat_length, deck_tasks)
	
	var cutscene_data = new_stage_data.cutscene_data
	if cutscene_data:
		dialog_box.left_texture = cutscene_data.left_texture
		dialog_box.left_sound = cutscene_data.left_sound

		dialog_box.right_texture = cutscene_data.right_texture
		dialog_box.right_sound = cutscene_data.right_sound

		dialog_box.dialog_data = cutscene_data.dialog_data
		dialog_box.initialize()

func initialize(new_stage_data: StageData):
	stage_data = new_stage_data
	if is_node_ready():
		load_stage_data(stage_data)

func _on_continue_pressed() -> void:
	start_pressed.emit(stage_data)

func _on_skip_pressed() -> void:
	skip_pressed.emit()

func pause_play():
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	if dialog_box:
		dialog_box.process_mode = ProcessMode.PROCESS_MODE_DISABLED

func resume_play(new_mouse_mode: int = Input.MOUSE_MODE_VISIBLE):
	process_mode = ProcessMode.PROCESS_MODE_INHERIT
	if dialog_box:
		dialog_box.process_mode = ProcessMode.PROCESS_MODE_ALWAYS
		dialog_box.update_view()
