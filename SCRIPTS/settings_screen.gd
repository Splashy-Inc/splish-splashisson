extends Control

signal exited

@onready var all_slider: HSlider = $ScreenRows/Settings/SettingsTabContainer/Audio/ControlsGrid/AllSlider
@onready var music_slider: HSlider = $ScreenRows/Settings/SettingsTabContainer/Audio/ControlsGrid/MusicSlider
@onready var effects_slider: HSlider = $ScreenRows/Settings/SettingsTabContainer/Audio/ControlsGrid/EffectsSlider

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
		all_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
		effects_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects")))

func _on_all_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_effects_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(value))
