extends Node

signal save_requested(new_stages_data: Array[StageData], game_mode: Globals.Game_mode)
signal save_completed(saved_resource: SaveData, game_mode: Globals.Game_mode)

signal load_requested(game_mode: Globals.Game_mode)
signal load_completed(loaded_resource: SaveData, game_mode: Globals.Game_mode)

signal clear_saves_requested

var story_save_resource := preload("res://Custom Resources/SaveData/story_save_data.tres")
var story_save_path := "user://story.tres"

var free_play_save_resource := preload("res://Custom Resources/SaveData/free_play_save_data.tres")
var free_play_save_path := "user://free_play.tres"

var default_save_resource := preload("res://Custom Resources/SaveData/default_save_data.tres")

func _ready() -> void:
	save_requested.connect(_on_save_requested)
	load_requested.connect(_on_load_requested)
	clear_saves_requested.connect(_on_clear_saves_requested)
	
	story_save_resource.stages = copy_save_data_resource(default_save_resource).stages
	free_play_save_resource.stages = copy_save_data_resource(default_save_resource).stages
	for stage in free_play_save_resource.stages:
		stage.unlocked = true
	
	load_requested.emit(Globals.Game_mode.STORY)
	load_requested.emit(Globals.Game_mode.FREE_PLAY)

func _on_save_requested(new_stages_data: Array[StageData], game_mode: Globals.Game_mode):
	var save_path = ""
	var save_resource : SaveData
	match game_mode:
		Globals.Game_mode.STORY:
			save_path = story_save_path
			story_save_resource.stages = new_stages_data
			save_resource = story_save_resource
		Globals.Game_mode.FREE_PLAY:
			save_path = free_play_save_path
			free_play_save_resource.stages = new_stages_data
			for stage in free_play_save_resource.stages:
				stage.unlocked = true
			save_resource = free_play_save_resource
	
	if save_path != "" and save_resource:
		save_resource = copy_save_data_resource(save_resource)
		ResourceSaver.save(save_resource, save_path)
		save_completed.emit(save_resource, game_mode)

func _on_load_requested(game_mode: Globals.Game_mode):
	var load_path = ""
	var load_resource = default_save_resource.duplicate(true) as SaveData
	match game_mode:
		Globals.Game_mode.STORY:
			load_path = story_save_path
			load_resource = story_save_resource
		Globals.Game_mode.FREE_PLAY:
			load_path = free_play_save_path
			load_resource = free_play_save_resource
	
	if ResourceLoader.exists(load_path):
		var loaded_data = load(load_path)
		if loaded_data is SaveData:
			load_resource.stages = loaded_data.stages
	load_completed.emit(load_resource, game_mode)

func _on_clear_saves_requested():
	if ResourceLoader.exists(story_save_path):
		save_requested.emit(copy_save_data_resource(default_save_resource).stages, Globals.Game_mode.STORY)
	
	if ResourceLoader.exists(free_play_save_path):
		save_requested.emit(copy_save_data_resource(default_save_resource).stages, Globals.Game_mode.FREE_PLAY)

func get_loaded_data(game_mode: Globals.Game_mode):
	var load_resource : SaveData
	match game_mode:
		Globals.Game_mode.STORY:
			load_resource =  story_save_resource
		Globals.Game_mode.FREE_PLAY:
			load_resource = free_play_save_resource
	
	load_completed.emit(load_resource, load_resource.game_mode)
	return load_resource

func copy_save_data_resource(resource_to_copy: SaveData):
	var copy := resource_to_copy.duplicate() as SaveData
	var copy_stages : Array[StageData]
	for stage in resource_to_copy.stages:
		var stage_copy = stage.duplicate()
		stage.level_stats = stage.level_stats.duplicate()
		copy_stages.append(stage.duplicate())
	copy.stages = copy_stages
	return copy
