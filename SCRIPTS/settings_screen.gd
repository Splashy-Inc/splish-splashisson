extends Control

signal exited

@export var settings : Settings

@onready var settings_tab_container: TabContainer = $ScreenRows/Settings/SettingsTabContainer

@onready var all_slider: HSlider = $ScreenRows/Settings/SettingsTabContainer/Audio/ControlsGrid/AllSlider
@onready var music_slider: HSlider = $ScreenRows/Settings/SettingsTabContainer/Audio/ControlsGrid/MusicSlider
@onready var effects_slider: HSlider = $ScreenRows/Settings/SettingsTabContainer/Audio/ControlsGrid/EffectsSlider

@onready var morale_aura_check_button: CheckButton = $ScreenRows/Settings/SettingsTabContainer/Game/VBoxContainer/ControlsGrid/MoraleAuraCheckButton

@onready var clear_save_button: Button = $ScreenRows/Settings/SettingsTabContainer/Game/VBoxContainer/ClearSaveButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_back_button_pressed() -> void:
	if visible:
		exited.emit()

func _on_visibility_changed() -> void:
	if visible:
		settings_tab_container.current_tab = 0
		load_settings(Globals.settings)
		all_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
		effects_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects")))
		clear_save_button.text = "Clear Save Data"
		clear_save_button.disabled = false

func _on_all_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_effects_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(value))

func _on_morale_aura_check_button_toggled(toggled_on: bool) -> void:
	settings.player_aura_visible = toggled_on
	Globals.update_settings(settings)

func load_settings(new_settings):
	settings = new_settings
	
	morale_aura_check_button.button_pressed = settings.player_aura_visible

func _on_settings_tab_container_visibility_changed() -> void:
	if settings_tab_container.visible:
		settings_tab_container.get_tab_bar().grab_focus()

func _on_clear_save_button_pressed() -> void:
	SaveEvents.clear_saves_requested.emit()
	clear_save_button.text = "DATA CLEARD!"
	clear_save_button.disabled = true
