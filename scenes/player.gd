extends CharacterBody2D

# Scenes
const NET_SCENE = preload("res://scenes/creature_net.tscn")

# Inputs
const RIGHT_INPUT = "right"
const LEFT_INPUT = "left"
const JUMP_INPUT = "jump"
const THROW_INPUT = "use"

# Physics Constants
const TILE_SIZE = 32
const SPEED := TILE_SIZE * 5 # Pixels / second
const JUMP_HEIGHT := TILE_SIZE * 3 # Pixels
const JUMP_RELEASE_MULTIPLIER = 0.25

const NET_HEIGHT_OFFSET = 16

@export var gravity_scale := 1.0

@onready var gravity: float = ProjectSettings.get_setting(
	"physics/2d/default_gravity"
) * gravity_scale
@onready var jump_velocity = 2.0 * sqrt(gravity * JUMP_HEIGHT)

@onready var map: Map = get_parent()


var horizontal_input := 0.0 : set = _set_horizontal_input


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action(RIGHT_INPUT) or event.is_action(LEFT_INPUT):
		horizontal_input = Input.get_axis(LEFT_INPUT, RIGHT_INPUT)
	if event.is_action_pressed(THROW_INPUT):
		_throw_net()


func _physics_process(delta: float) -> void:
	var horizontal_velocity := horizontal_input * SPEED
	velocity.x = horizontal_velocity
	
	if not is_on_floor():
		velocity.y += 2 * gravity * delta
	elif Input.is_action_just_pressed(JUMP_INPUT):
		velocity.y -= jump_velocity
	
	if Input.is_action_just_released(JUMP_INPUT) and velocity.y < 0:
		velocity.y *= JUMP_RELEASE_MULTIPLIER
	
	move_and_slide()


func _throw_net() -> void:
	var direction := get_local_mouse_position().normalized()
	var net := NET_SCENE.instantiate()
	net.position = global_position + Vector2.UP * NET_HEIGHT_OFFSET
	map.add_projectile(net)
	net.throw(direction)


func _set_horizontal_input(new_horizontal_input: float) -> void:
	horizontal_input = new_horizontal_input
	if sign(horizontal_input) == -1:
		$Sprite.flip_h = true
	elif sign(horizontal_input) == 1:
		$Sprite.flip_h = false
