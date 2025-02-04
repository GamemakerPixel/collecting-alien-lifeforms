extends Area2D

const UNLOAD_INPUT = "interact"
const LEAVE_INPUT = "leave"

const SHIP_SCENE = "res://scenes/maps/space_ship.tscn"

var player_in_range := false : set = _set_player_in_range
var player: Node2D = null
var remove_messages: Callable = func(): pass


func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range:
		return
	if event.is_action_pressed(UNLOAD_INPUT):
		var incomplete: bool = Inventory.transfer_inventory_contents(
			Inventory.Type.PLAYER, Inventory.Type.SHIP
		)
		if incomplete:
			player.push_ship_full_message()
		else:
			player.push_successful_unload_message(
				Inventory.get_capacity_remaining(Inventory.Type.SHIP)
			)
			$Unload.play()
	elif event.is_action_pressed(LEAVE_INPUT):
		get_tree().change_scene_to_file(SHIP_SCENE)


func _on_player_entered(body: Node2D) -> void:
	player = body
	player_in_range = true


func _on_player_exited(body: Node2D) -> void:
	player = null
	player_in_range = false


func _set_player_in_range(new_player_in_range: bool) -> void:
	player_in_range = new_player_in_range
	if player_in_range:
		remove_messages = player.show_ship_in_range_messages()
	else:
		remove_messages.call()
		remove_messages = func(): pass
