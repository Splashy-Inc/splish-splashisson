extends Label

class_name StopWatch

var total_seconds = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start()
	Globals.level_completed.connect(_on_level_completed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start():
	$Timer.start()

func stop():
	$Timer.stop()

func _on_timer_timeout() -> void:
	total_seconds += 1
	if Globals.level:
		Globals.level.set_finish_seconds(total_seconds)
	_update_time()

func _update_time():
	text = time_string_from_seconds(total_seconds)
	
static func time_string_from_seconds(new_seconds: int):
	var minutes = int(new_seconds / 60)
	var seconds = new_seconds % 60
	
	var min_str = str(minutes)
	var sec_str = str(seconds)
	
	if minutes < 10:
		min_str = "0" + str(minutes)
	if seconds < 10:
		sec_str = "0" + str(seconds)

	return min_str + ":" + sec_str
	
func _on_level_completed(level: Level):
	$Timer.stop()
