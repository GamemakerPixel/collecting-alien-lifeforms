extends State

const MIN_WALK_TIME = 1.0
const MAX_WALK_TIME = 4.0

const FLIP_DIRECTION_PROBABILITY = 0.4

const WALK_SPEED = 96

@export var creature: AnglerToad

var walk_timer: Timer = null


func enter() -> void:
	_decide_move_direction()
	creature.size_jump_ray(WALK_SPEED)
	_set_walk_timer()
	creature.hearing_area.body_entered.connect(_on_player_heard)
	creature.animation.play("normal")
	process_mode = ProcessMode.PROCESS_MODE_INHERIT


func exit() -> void:
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	walk_timer.queue_free()
	creature.hearing_area.body_entered.disconnect(_on_player_heard)


func _physics_process(delta: float) -> void:
	creature.move(WALK_SPEED)
	creature.jump_if_should()
	creature.fall(delta)
	creature.move_and_slide()


func _decide_move_direction() -> void:
	if randf() < FLIP_DIRECTION_PROBABILITY:
		creature.move_direction *= -1


func _set_walk_timer() -> void:
	walk_timer = Timer.new()
	walk_timer.wait_time = randf_range(MIN_WALK_TIME, MAX_WALK_TIME)
	walk_timer.one_shot = true
	add_child(walk_timer)
	walk_timer.timeout.connect(_on_walk_timeout)
	walk_timer.start()


func _on_walk_timeout() -> void:
	state_machine.change_state_to(AnglerToad.States.IDLE)


func _on_player_heard(player: Node2D) -> void:
	creature.face_away_from(player.position)
	state_machine.change_state_to(AnglerToad.States.RUN)
