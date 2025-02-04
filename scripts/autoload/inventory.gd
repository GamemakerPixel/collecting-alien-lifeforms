extends Node

enum Type {
	PLAYER,
	SHIP,
}

enum Item {
	ANGLER_TOAD,
	MUSHROOM,
}

const ITEM_SIZES = {
	Item.ANGLER_TOAD: 2,
	Item.MUSHROOM: 1,
}
const INVENTORY_CAPACITIES = {
	Type.PLAYER: 5,
	Type.SHIP: 50,
}

# {CreatureItem: count (int)}
var inventories = {
	Type.PLAYER: {},
	Type.SHIP: {},
}

var capacity_used = {
	Type.PLAYER: 0,
	Type.SHIP: 0,
}


func get_count(inventory: Type, item: Item) -> int:
	if not item in inventories[inventory].keys():
		return 0
	return inventories[inventory][item]


func can_fit(inventory: Type, item: Item) -> int:
	var avaliable_capacity: int = (
		INVENTORY_CAPACITIES[inventory] - capacity_used[inventory]
	)
	@warning_ignore("integer_division")
	return avaliable_capacity / ITEM_SIZES[item]


func can_fit_at_least(inventory: Type, item: Item, count: int) -> bool:
	return can_fit(inventory, item) >= count

# Returns true if successfully added items.
func add_item(inventory: Type, item: Item, count: int) -> bool:
	if not can_fit_at_least(inventory, item, count):
		return false
	
	_add_item_no_check(inventory, item, count)
	return true

# Returns the number of items that were not able to be added.
func add_items_as_avaliable(inventory: Type, item: Item, max_count: int) -> int:
	var able_to_add := can_fit(inventory, item)
	
	var count_to_add := mini(able_to_add, max_count)
	
	_add_item_no_check(inventory, item, count_to_add)
	return max_count - count_to_add


func get_capacity_remaining(inventory: Type) -> int:
	return INVENTORY_CAPACITIES[inventory] - capacity_used[inventory]


func _add_item_no_check(inventory: Type, item: Item, count: int) -> void:
	if count == 0:
		return
	
	var items: Dictionary = inventories[inventory]
	inventories[inventory][item] = get_count(inventory, item) + count
	capacity_used[inventory] += ITEM_SIZES[item] * count


func _remove_item_no_check(inventory: Type, item: Item, count: int) -> void:
	if count == 0:
		return
	
	var items: Dictionary = inventories[inventory]
	inventories[inventory][item] = get_count(inventory, item) - count
	capacity_used[inventory] -= ITEM_SIZES[item] * count
	if inventories[inventory][item] <= 0:
		inventories[inventory].erase(item)


# Returns true if all items transfered, false otherwise.
func transfer_inventory_contents(from: Type, to: Type) -> bool:
	var incomplete_flag := false
	
	for item in inventories[from].keys():
		var count_avaliable := get_count(from, item)
		var count_remaining := add_items_as_avaliable(to, item, count_avaliable)
		var removed := count_avaliable - count_remaining
		_remove_item_no_check(from, item, removed)
		
		if count_remaining > 0:
			incomplete_flag = true
	
	return incomplete_flag
