extends State

const MIN_RUN_TIME = 3.0
const MAX_RUN_TIME = 5.0

const RUN_SPEED = 160

@export var creature: AnglerToad

var run_timer: Timer = null


func enter() -> void:
	creature.size_jump_ray(RUN_SPEED)
	_create_run_timer()
	_set_run_timer()
	creature.animation.play("startled")
	process_mode = ProcessMode.PROCESS_MODE_INHERIT


func exit() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	run_timer.queue_free()


func _physics_process(delta: float) -> void:
	creature.move(RUN_SPEED)
	creature.jump_if_should()
	creature.fall(delta)
	creature.move_and_slide()


func _create_run_timer() -> void:
	run_timer = Timer.new()
	run_timer.one_shot = true
	add_child(run_timer)
	run_timer.timeout.connect(_on_run_timeout)


func _set_run_timer() -> void:
	run_timer.wait_time = randf_range(MIN_RUN_TIME, MAX_RUN_TIME)
	run_timer.start()


func _on_run_timeout() -> void:
	if creature.hearing_area.has_overlapping_bodies():
		_set_run_timer()
		return
	state_machine.change_state_to(AnglerToad.States.IDLE)
