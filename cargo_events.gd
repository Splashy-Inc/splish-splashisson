extends Node

signal cargo_changed(new_cargo: Cargo)
signal condition_updated(new_condition: int, max_condition: int)
signal threats_changed(threats: Array)

var cur_cargo: Cargo

func _ready():
	cargo_changed.connect(_on_cargo_changed)

func _on_cargo_changed(new_cargo: Cargo):
	cur_cargo = new_cargo
