extends CanvasLayer

const TIMED_MESSAGE_DURATION = 5.0

const PLAYER_INVENTORY_FULL_MESSAGE = "Your inventory is too full to pick this up!"
const SHIP_IN_RANGE_MESSAGE = "Press E to load creatures into the ship and R to leave."
const SUCCESSFUL_UNLOAD_MESSAGE = "Successfully unloaded. Remaining ship capacity: %d"
const INCOMPLETE_UNLOAD_MESSAGE = "Unable to fully unload, ship is full."


func message_player_inventory_full() -> void:
	$MessageBoard.push_timed_message(PLAYER_INVENTORY_FULL_MESSAGE, TIMED_MESSAGE_DURATION)


func message_ship_in_range() -> Callable:
	return $MessageBoard.push_conditional_message(SHIP_IN_RANGE_MESSAGE)


func message_successful_unload(remaining_capacity: int) -> void:
	return $MessageBoard.push_timed_message(
		SUCCESSFUL_UNLOAD_MESSAGE % remaining_capacity,
		TIMED_MESSAGE_DURATION
	)


func message_incomplete_unload() -> void:
	return $MessageBoard.push_timed_message(
		INCOMPLETE_UNLOAD_MESSAGE,
		TIMED_MESSAGE_DURATION
	)
