extends Node

@export var level_scene: PackedScene
@export var cutscene_scene: PackedScene
@export var tutorial_scene: PackedScene
@export var game_mode_data : SaveData
@export var cur_stage_data : StageData

@onready var sfx_manager: SFXManager = $SFXManager
@onready var hud: HUD = $HUD
var game_ended = false
var paused = true
var cur_screen : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	show_main_menu()
	sfx_manager.play("MainTheme")
	game_mode_data = game_mode_data.duplicate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _resume_play(mouse_mode: int = Input.MOUSE_MODE_VISIBLE):
	paused = false
	hud.hide_menus()
	if cur_screen and cur_screen.has_method("resume_play"):
		cur_screen.resume_play(mouse_mode)

func _pause_play():
	paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if cur_screen and cur_screen.has_method("pause_play"):
		cur_screen.pause_play()

func show_main_menu():
	_pause_play()
	_clear_screens()
	cur_stage_data = null
	hud.show_main_menu()

func show_levels_menu():
	_pause_play()
	_clear_screens()
	hud.show_levels_menu()

func toggle_pause_menu():
	match hud.cur_menu:
		HUD.Menus.MAIN:
			pass
		HUD.Menus.CONTROLS:
			hud._go_back_screen()
		HUD.Menus.SETTINGS:
			hud._go_back_screen()
		HUD.Menus.LEVELS:
			hud._go_back_screen()
		_:
			if not paused:
				_pause_play()
				hud.show_pause_menu()
			else:
				_resume_play()

func show_end_game_screen():
	_pause_play()
	_clear_screens()
	cur_stage_data = null
	hud.show_end_game_screen()

func _on_quit_pressed():
	get_tree().quit()

func _on_play_pressed(stage_data: StageData = null):
	if not cur_screen or stage_data:
		if stage_data:
			load_stage(stage_data)
		elif cur_stage_data:
			load_stage(cur_stage_data)
		else:
			load_stage(game_mode_data.stages.front())
	_resume_play()

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause_menu()

func _restart_screen():
	game_ended = false
	
	if cur_stage_data:
		if cur_screen is Level:
			load_level(cur_stage_data)
		elif cur_screen is Cutscene:
			load_stage(cur_stage_data)
	else:
		show_main_menu()

func _on_restart_pressed():
	_restart_screen()
	_resume_play()

func _on_level_lost():
	game_ended = true
	hud.show_loss_screen()

func _on_level_won():
	game_ended = true
	_pause_play()
	hud.show_win_screen()

func _on_stage_selected(new_stage_data: StageData):
	_set_stage(new_stage_data)

func _set_stage(new_stage_data: StageData):
	cur_stage_data = new_stage_data

func _on_main_menu_pressed() -> void:
	show_main_menu()

func _on_level_completed():
	game_ended = true
	#_pause_play()
	unlock_next_stage(cur_stage_data)
	SaveEvents.save_requested.emit(game_mode_data.stages, game_mode_data.game_mode)
	hud.show_win_screen(cur_stage_data.level_stats)
	
func _on_tutorial_completed():
	game_ended = true
	_pause_play()
	hud.show_win_screen()

func _on_tutorial_skipped():
	unlock_next_stage(cur_stage_data)
	SaveEvents.save_requested.emit(game_mode_data.stages, game_mode_data.game_mode)
	show_levels_menu()

func _clear_screens():
	if is_instance_valid(cur_screen):
		cur_screen.queue_free()
	cur_screen = null
	Globals.set_level(null)

func _on_next_pressed() -> void:
	if cur_screen:
		hud.hide_menus()
		if cur_screen is Level:
			if cur_stage_data == game_mode_data.stages.back():
				show_end_game_screen()
			else:
				show_levels_menu()
		elif cur_screen is Cutscene:
			load_level(cur_stage_data)
	else:
		show_main_menu()

func load_level(stage_data: StageData):
	_set_stage(stage_data)
	_clear_screens()
	var new_level = generate_level(stage_data.is_tutorial)
	new_level.completed.connect(_on_level_completed)
	for sig in new_level.get_signal_list():
		match sig["name"]:
			"lost":
				new_level.lost.connect(_on_level_lost)
			"won":
				new_level.won.connect(_on_level_won)
			#"tutorial_completed":
				#new_level.tutorial_completed.connect(_on_tutorial_won)
	add_child(new_level)
	new_level.initialize(cur_stage_data)
	cur_screen = new_level
	Globals.set_level(new_level)

func load_stage(new_stage_data: StageData):
	_set_stage(new_stage_data)
	_clear_screens()
	var new_cutscene = generate_cutscene()
	new_cutscene.start_pressed.connect(_on_cutscene_start_pressed)
	new_cutscene.skip_pressed.connect(_on_tutorial_skipped)
	add_child(new_cutscene)
	new_cutscene.initialize(cur_stage_data)
	cur_screen = new_cutscene
	Globals.set_level(null)

# Unused, but still keeping this in here in case we end up wanting it again
func load_next_stage():
	if cur_stage_data:
		var cur_stage_index = game_mode_data.stages.find(cur_stage_data)
		if cur_stage_index < game_mode_data.stages.size() - 1:
			load_stage(game_mode_data.stages[cur_stage_index + 1])
		else:
			show_end_game_screen()
	else:
		show_main_menu()

func generate_cutscene() -> Cutscene:
	# Calling duplicate() here as a workaround to this issue: https://github.com/godotengine/godot/issues/96181
	var new_cutscene = cutscene_scene.instantiate().duplicate() as Cutscene
	return new_cutscene

func generate_level(is_tutorial: bool = false) -> Level:
	# Calling duplicate() here as a workaround to this issue: https://github.com/godotengine/godot/issues/96181
	var new_level 
	if is_tutorial:
		new_level = tutorial_scene.instantiate().duplicate()
	else:
		new_level = level_scene.instantiate().duplicate()
	return new_level

func unlock_next_stage(cur_stage_data: StageData):
	var cur_stage_index = game_mode_data.stages.find(cur_stage_data)
	if cur_stage_index < game_mode_data.stages.size() - 1:
		game_mode_data.stages[cur_stage_index + 1].unlocked = true

func _on_cutscene_start_pressed(stage_data: StageData):
	if cur_screen is Cutscene:
		load_level(stage_data)

func _on_story_pressed() -> void:
	set_game_mode(Globals.Game_mode.STORY)

func _on_free_play_pressed() -> void:
	set_game_mode(Globals.Game_mode.FREE_PLAY)

func set_game_mode(new_mode: Globals.Game_mode):
	game_mode_data = SaveEvents.get_loaded_data(new_mode)
	if new_mode == Globals.Game_mode.STORY and not game_mode_data.stages[1].unlocked:
		_on_play_pressed(game_mode_data.stages.front())
		return
	show_levels_menu()
