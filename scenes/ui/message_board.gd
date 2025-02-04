extends Control


func push_timed_message(message: String, seconds: float) -> void:
	var label := _create_message(message)
	var timer := _create_timer(seconds)
	
	timer.timeout.connect(
		func(): _clear_timed_message(label, timer)
	)
	timer.start()


# Returns a callable that will remove the message when called.
func push_conditional_message(message: String) -> Callable:
	var label := _create_message(message)
	return func(): _clear_message(label)


func _create_message(message: String) -> Label:
	var label: Label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Messages.add_child(label)
	return label


func _create_timer(seconds: float) -> Timer:
	var timer: Timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = true
	$Timers.add_child(timer)
	return timer


func _clear_timed_message(message: Label, timer: Timer) -> void:
	_clear_message(message)
	timer.queue_free()

# Animations could go here later.
func _clear_message(message: Label) -> void:
	message.queue_free()
