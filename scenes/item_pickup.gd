extends Area2D

signal item_focused(item: Node2D)
signal item_unfocused(item: Node2D)

const ITEM_DISTANCE_WEIGHT = 1.0
const ITEM_ANGLE_WEIGHT = 100.0

var scanning := true : set = _set_scanning
var in_area: Array[Node2D] = []
var in_reach: Array[Node2D] = []
var focused_item: Node2D = null


func _physics_process(_delta: float) -> void:
	var mouse_direction := get_local_mouse_position().normalized()
	for body in in_area:
		var cost := _calculate_cost(body, mouse_direction)


func _on_body_entered(body: Node2D) -> void:
	in_area.append(body)


func _on_body_exited(body: Node2D) -> void:
	in_area.remove_at(in_area.find(body))


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
