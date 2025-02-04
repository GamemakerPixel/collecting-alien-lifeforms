extends State

@export var creature: AnglerToad


func enter() -> void:
	creature.velocity.x = 0.0
	creature.set_collision_grabbable(true)
	creature.animation.play("captured")
	process_mode = ProcessMode.PROCESS_MODE_INHERIT


func exit() -> void:
	creature.set_collision_grabbable(false)
	process_mode = ProcessMode.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	creature.fall(delta)
	creature.move_and_slide()
