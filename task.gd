extends StaticBody2D

var assignee: Crew

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# This function is intended to be set when the respective crew is in range of the task to begin work
func set_assignee(new_assignee: Crew):
	if new_assignee: # Only allow setting assignee if not already taken
		if assignee == null:
			new_assignee.hide()
			$AnimatedSprite2D.play("active")
	elif assignee: # Null being passed in means unassigning current assignee, so show them
		assignee.show()
		$AnimatedSprite2D.play("idle")
	
	assignee = new_assignee
