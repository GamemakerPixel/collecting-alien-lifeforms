extends State

const MIN_IDLE_TIME = 2.0
const MAX_IDLE_TIME = 5.0


@export var creature: AnglerToad

var idle_timer: Timer = null


func enter() -> void:
	_set_idle_timer()
	creature.velocity.x = 0.0
	creature.hearing_area.body_entered.connect(_on_player_heard)
	creature.modulate = Color.BLUE
	process_mode = ProcessMode.PROCESS_MODE_INHERIT


func exit() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	idle_timer.queue_free()
	creature.hearing_area.body_entered.disconnect(_on_player_heard)


func _physics_process(delta: float) -> void:
	creature.fall(delta)
	creature.move_and_slide()


func _set_idle_timer() -> void:
	idle_timer = Timer.new()
	idle_timer.wait_time = randf_range(MIN_IDLE_TIME, MAX_IDLE_TIME)
	idle_timer.one_shot = true
	add_child(idle_timer)
	idle_timer.timeout.connect(_on_idle_timeout)
	idle_timer.start()


func _on_idle_timeout() -> void:
	state_machine.change_state_to(AnglerToad.States.WALK)


func _on_player_heard(player: Node2D) -> void:
	creature.face_away_from(player.position)
	state_machine.change_state_to(AnglerToad.States.RUN)
