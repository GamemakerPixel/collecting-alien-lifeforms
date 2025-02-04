extends Sprite2D

@export var body: RigidBody2D

@onready var base_rotation = rotation


func _process(delta: float) -> void:
	var rotational_difference = Vector2.RIGHT.angle_to(body.linear_velocity)
	rotation = rotational_difference + base_rotation
