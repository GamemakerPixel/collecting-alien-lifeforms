extends CharacterBody2D
class_name Creature

const SELECTED_MATERIAL = preload("res://resources/outline.tres")

@export var item_type: Inventory.Item


func select() -> void:
	if has_node("Sprite"):
		$Sprite.material = SELECTED_MATERIAL


func deselect() -> void:
	if has_node("Sprite"):
		$Sprite.material = null


func get_item_type() -> Inventory.Item:
	return item_type


# This method must, in some way, prevent the player from redetecting the item.
# If an animation is triggered first, disable the collision.
func picked_up() -> void:
	queue_free()
