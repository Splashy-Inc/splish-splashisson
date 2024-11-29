extends StaticBody2D

class_name Task

@export var test_assignee: Crew
var assignee: Crew


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_test_assignment()

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

func _test_assignment():
	if test_assignee:
		print(self, " waiting 5 seconds to assign ", test_assignee)
		await get_tree().create_timer(5).timeout
		set_assignee(test_assignee)
		print(test_assignee, " assigned to ", self)
		print(self, " waiting 5 seconds to unassign ", test_assignee)
		await get_tree().create_timer(5).timeout
		set_assignee(null)
		print(test_assignee, " unassigned from ", self)
