extends RigidBody2D

const THROW_SPEED = 500.0


func throw(direction: Vector2) -> void:
	apply_impulse(THROW_SPEED * direction)


func _on_body_entered(body: Node) -> void:
	if body.has_method("netted"):
		body.netted()
	queue_free()
