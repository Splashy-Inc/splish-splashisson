extends CanvasLayer

class_name HUD

signal play_pressed
signal restart_pressed
signal quit_pressed
signal main_menu_pressed

@onready var menu_screens: Control = $MenuScreens
@onready var menu_back_ground: ColorRect = $MenuScreens/MenuBackGround
@onready var main_menu: Control = $MenuScreens/MainMenu
@onready var controls_screen: Control = $MenuScreens/ControlsScreen
@onready var win_screen: Control = $MenuScreens/WinScreen
@onready var loss_screen: Control = $MenuScreens/LossScreen
@onready var pause_menu: Control = $MenuScreens/PauseMenu

enum Menus {
	NONE,
	MAIN,
	CONTROLS,
	WIN,
	LOSS,
	PAUSE,
}

var cur_menu := Menus.NONE
var prev_menu := Menus.NONE

func _ready():
	pass

func _process(delta):
	pass

func hide_menus():
	hide_menu_screens()

func _clear_menu():
	for child in menu_screens.get_children():
		if child != menu_back_ground:
			child.hide()

func show_menu_screens():
	menu_screens.show()

func hide_menu_screens():
	cur_menu = Menus.NONE
	_clear_menu()
	menu_screens.hide()

func _on_controls_screen_exited():
	_go_back_screen()

func _go_back_screen():
	match prev_menu:
		Menus.PAUSE:
			show_pause_menu()
		_:
			show_main_menu()

func _show_controls():
	prev_menu = cur_menu
	cur_menu = Menus.CONTROLS
	_clear_menu()
	show_menu_screens()
	controls_screen.show()

func show_main_menu():
	cur_menu = Menus.MAIN
	_clear_menu()
	show_menu_screens()
	main_menu.show()

func show_pause_menu():
	cur_menu = Menus.PAUSE
	_clear_menu()
	show_menu_screens()
	pause_menu.show()

func show_win_screen():
	cur_menu = Menus.WIN
	_clear_menu()
	show_menu_screens()
	win_screen.show()

func show_loss_screen():
	cur_menu = Menus.LOSS
	_clear_menu()
	show_menu_screens()
	loss_screen.show()

func _on_game_menu_button_pressed(type: String):
	match type:
		"Play":
			play_pressed.emit()
		"Restart":
			restart_pressed.emit()
		"Controls":
			_show_controls()
		"Main menu":
			main_menu_pressed.emit()
		"Quit":
			quit_pressed.emit()
