extends Level

func _ready() -> void:
	if stage_data:
		load_stage_data(stage_data)
	else:
		load_level()
