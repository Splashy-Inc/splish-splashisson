extends PanelContainer

var progress_percent = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.level_progress_percent_updated.connect(_on_level_progress_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_level_progress_updated(percent: float):
	progress_percent = percent
	update_progress()

func update_progress():
	$MapProgress.value = progress_percent * 100
	$VBoxContainer/BoatIcon.position.x = $MapProgress.size.x * progress_percent - $VBoxContainer/BoatIcon.size.x
