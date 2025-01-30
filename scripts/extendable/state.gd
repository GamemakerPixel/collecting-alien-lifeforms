# From Aidan's previous prototype (with modification).
extends Node
class_name State

@onready var state_machine: StateMachine = get_parent()


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED


func enter() -> void:
	pass


func exit() -> void:
	pass
