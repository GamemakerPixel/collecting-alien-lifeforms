extends Area2D

signal item_focused(item: Node2D)
signal item_unfocused(item: Node2D)

const ITEM_DISTANCE_WEIGHT = 1.0
const ITEM_ANGLE_WEIGHT = 100.0

var scanning := true : set = _set_scanning
var in_area: Array[Node2D] = []
var focused_item: Node2D = null : set = _set_focused_item


func _process(_delta: float) -> void:
	_focus_nearest_item()


func _focus_nearest_item() -> void:
	var mouse_direction := get_local_mouse_position().normalized()
	var min_cost: float = 1000000000.0 # There doesn't appear to be a constant for max values...
	var item_to_focus: Node2D = null
	for body in in_area:
		var cost := _calculate_cost(body, mouse_direction)
		if cost < min_cost:
			min_cost = cost
			item_to_focus = body
	
	focused_item = item_to_focus


func _on_body_entered(body: Node2D) -> void:
	in_area.append(body)


func _on_body_exited(body: Node2D) -> void:
	in_area.remove_at(in_area.find(body))
	if body == focused_item:
		_focus_nearest_item()


func _set_scanning(new_scanning: bool) -> void:
	scanning = new_scanning
	if scanning:
		process_mode = ProcessMode.PROCESS_MODE_INHERIT
	else:
		process_mode = ProcessMode.PROCESS_MODE_DISABLED


func _calculate_cost(body: Node2D, mouse_direction: Vector2) -> float:
	var vector := body.position - position
	var distance := vector.length()
	var angle := absf(vector.angle_to(mouse_direction))
	
	return distance * ITEM_DISTANCE_WEIGHT + angle * ITEM_ANGLE_WEIGHT


func _set_focused_item(new_focused_item: Node2D) -> void:
	if new_focused_item != focused_item:
		if focused_item != null:
			focused_item.deselect()
		if new_focused_item != null:
			new_focused_item.select()
	focused_item = new_focused_item
