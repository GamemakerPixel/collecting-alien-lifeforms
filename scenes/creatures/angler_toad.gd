extends Creature
class_name AnglerToad

enum States {
	IDLE,
	WALK,
	RUN,
	BOUND,
}

const JUMP_HEIGHT = 32 * 1.5
const JUMP_RAY_EXTRA_WIDTH = 15.0

@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var jump_velocity: float = 2.0 * sqrt(gravity * JUMP_HEIGHT)

@onready var jump_ray: RayCast2D = $JumpRay
@onready var hearing_area: Area2D = $Hearing
@onready var animation: AnimationPlayer = $Animation

# x axis direction, 1 = right, -1 = left
var move_direction := 1 : set = _set_move_direction


func _ready() -> void:
	_initialize_states()
	$States.change_state_to(States.IDLE)


func move(speed: float) -> void:
	velocity.x = speed * move_direction


func fall(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 2.0 * gravity * delta


func size_jump_ray(speed: float) -> void:
	# Absolute value is needed should either be negative.
	var jump_time: float = jump_velocity / gravity
	var half_jump_distance := jump_time / 2.0 * speed
	$JumpRay.target_position = $JumpRay.target_position.normalized() * (
		half_jump_distance + JUMP_RAY_EXTRA_WIDTH
	)


func jump_if_should() -> void:
	if jump_ray.is_colliding() and is_on_floor():
		velocity.y -= jump_velocity
		animation.play("jump")


func netted() -> void:
	$States.change_state_to(States.BOUND)


func face_away_from(pos: Vector2) -> void:
	var away_vector := position - pos
	move_direction = sign(away_vector.x)


func set_collision_grabbable(grabbable: bool) -> void:
	if grabbable:
		collision_layer = 0b00000100
	else:
		collision_layer = 0b00001000


func picked_up() -> void:
	$CollisionShape2D.disabled = true
	animation.animation_finished.connect(
		func(_anim_name: String): queue_free()
	)
	animation.process_mode = Node.PROCESS_MODE_ALWAYS
	process_mode = ProcessMode.PROCESS_MODE_DISABLED
	animation.play("picked_up")


func _initialize_states() -> void:
	$States.states = {
		States.IDLE: $States/Idle,
		States.WALK: $States/Walk,
		States.RUN: $States/Run,
		States.BOUND: $States/Bound,
	}


func _set_move_direction(new_move_direction: int) -> void:
	move_direction = new_move_direction
	var direction := Vector2(move_direction, 0)
	jump_ray.target_position = direction * jump_ray.target_position.length()
	if move_direction == -1:
		$Sprite.flip_h = false
	elif move_direction == 1:
		$Sprite.flip_h = true
