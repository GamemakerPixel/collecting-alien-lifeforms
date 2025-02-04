extends Creature


func picked_up() -> void:
	$Collision.disabled = true
	$Animation.animation_finished.connect(
		func(_anim_name: String): queue_free()
	)
	$Animation.play("picked_up")
