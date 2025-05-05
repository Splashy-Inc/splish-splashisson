extends Label

var total_seconds = 0
var seconds = 0
var minutes = 0
var finish_seconds = 0

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
	seconds += 1
	if seconds == 60:
		seconds = 0
		minutes += 1
	_update_time()

func _update_time():
	var min_str = str(minutes)
	var sec_str = str(seconds)
	
	if minutes < 10:
		min_str = "0" + str(minutes)
	if seconds < 10:
		sec_str = "0" + str(seconds)

	text = min_str + ":" + sec_str
	
func _on_level_completed(level: Level):
	$Timer.stop()
	finish_seconds = total_seconds
