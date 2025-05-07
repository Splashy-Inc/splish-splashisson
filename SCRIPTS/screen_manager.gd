extends Node

var level_scene: PackedScene
var cutscene_scene: PackedScene
@export var start_scene: PackedScene

@onready var hud: HUD = $HUD
var cutscene: Cutscene
var level: Level
var game_ended = false
var paused = true
var cur_screen

# Called when the node enters the scene tree for the first time.
func _ready():
	show_main_menu()

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
	cutscene_scene = null
	level_scene = null
	hud.show_main_menu()

func toggle_pause_menu():
	if hud.cur_menu != HUD.Menus.MAIN and hud.cur_menu != HUD.Menus.CONTROLS:
		if not paused:
			_pause_play()
			hud.show_pause_menu()
		else:
			_resume_play()

func _on_quit_pressed():
	get_tree().quit()

func _on_play_pressed():
	if cur_screen:
		_resume_play()
	else:
		if cutscene_scene:
			_on_start_cutscene()
		elif level_scene:
			_on_restart_pressed()
		else:
			cutscene_scene = start_scene
			_on_start_cutscene()

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause_menu()

func _restart_level():
	game_ended = false
	_clear_screens()
	
	# Calling duplicate() here as a workaround to this issue: https://github.com/godotengine/godot/issues/96181
	var new_level = level_scene.instantiate().duplicate()
	add_child(new_level)
	new_level.completed.connect(_on_level_completed)
	
	for sig in new_level.get_signal_list():
		match sig["name"]:
			"lost":
				new_level.lost.connect(_on_level_lost)
			"won":
				new_level.won.connect(_on_level_won)
			#"tutorial_completed":
				#new_level.tutorial_completed.connect(_on_tutorial_won)
	
	level = new_level
	Globals.set_level(level)
	cur_screen = level
	
	#_resume_play(Input.MOUSE_MODE_CAPTURED)

func _on_restart_pressed():
	if cur_screen is Cutscene:
		_on_start_cutscene()
	elif cur_screen is Level:
		_restart_level()
	_resume_play()

func _on_level_lost():
	game_ended = true
	hud.show_loss_screen()

func _on_level_won():
	game_ended = true
	_pause_play()
	hud.show_win_screen()

func _on_level_selected(new_level_scene: PackedScene):
	_set_level(new_level_scene)

func _set_level(new_level_scene: PackedScene):
	level_scene = new_level_scene

func _on_main_menu_pressed() -> void:
	show_main_menu()

func _on_level_completed():
	game_ended = true
	#_pause_play()
	hud.show_win_screen()
	
func _on_tutorial_completed():
	game_ended = true
	_pause_play()
	hud.show_tutorial_win_screen()

func _on_start_level(new_level_scene: PackedScene):
	if new_level_scene:
		level_scene = new_level_scene
	_restart_level()
	if cutscene:
		cutscene.queue_free()

func _on_start_cutscene():
	_clear_screens()
	
	# Calling duplicate() here as a workaround to this issue: https://github.com/godotengine/godot/issues/96181
	cutscene = cutscene_scene.instantiate().duplicate()
	add_child(cutscene)
	cutscene.start_pressed.connect(_on_start_level)
	if cutscene is TutorialCutscene:
		cutscene.tutorial_skipped.connect(_on_tutorial_skipped.bind(cutscene))
	_set_level(cutscene.level_scene)
	cur_screen = cutscene
	_resume_play()

func _on_tutorial_skipped(tutorial_cutscene: TutorialCutscene):
	if tutorial_cutscene.level_1_cutscene:
		cutscene_scene = tutorial_cutscene.level_1_cutscene
		_on_start_cutscene()
		tutorial_cutscene.queue_free()

func _clear_screens():
	if level:
		level.queue_free()
		level = null
	if cutscene:
		cutscene.queue_free()
		cutscene = null
	cur_screen = null
	Globals.set_level(null)

func _on_next_pressed() -> void:
	if level.next_scene:
		var next_scene = level.next_scene.instantiate()
		if next_scene is Cutscene:
			cutscene_scene = level.next_scene
			_on_start_cutscene()
		elif next_scene is Level:
			level_scene = level.next_scene
			_on_start_level(null)
	hud.hide_menus()
