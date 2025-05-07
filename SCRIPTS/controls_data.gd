extends Resource

class_name ControlsData

const AVAILABLE_CONTROLS := {
	"movement": "",
	"select": "",
	"act": "",
}

@export var keyboard_and_mouse := AVAILABLE_CONTROLS
@export var keyboard_only := AVAILABLE_CONTROLS
@export var controller := AVAILABLE_CONTROLS
@export var mobile := AVAILABLE_CONTROLS
