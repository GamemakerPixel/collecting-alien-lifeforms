extends Map

enum BackgroundTile {
	GRASS,
	TREE,
}

const TILE_SIZE = 32
const FLAT_TILE_ATLAS_COORDS = Vector2i(1, 0)

const TREE_PROBABILITY = 0.5
const GRASS_PROBABILITY = 0.5

@export_category("Generation Noise")
@export var height_noise: Noise # Only x axis used

@export_category("Generation Parameters")
@export var map_width: int = 1000 # This will be obsolete with an unlimited chunking system.
@export var minimum_height: int = 1
@export var maximum_height: int = 15

@export_category("Player Spawn")
@export var return_ship_scene: PackedScene
@export var player_scene: PackedScene

@export_category("Creature Spawning")
@export var creatures: Array[PackedScene]
@export var creature_spawn_probabilities: Array[float] # per spawnable tile.
@export var creature_flat_surface_required: Array[bool]

@export_category("Tiles")
@export var ground_tiles: TileMapLayer
@export var background_tiles: TileMapLayer

var surface_tiles: Array[Vector2i] = []
var flat_surface_ranges: Array[Vector2i] = []


func _ready() -> void:
	super._ready()
	_randomize_noise()
	_generate_ground()
	_find_flat_surface_ranges()
	_generate_background()
	_spawn_creatures()
	_spawn_player()


func _randomize_noise() -> void:
	height_noise.seed = randi()


func _generate_ground() -> void:
	ground_tiles.clear()
	
	var ground_cells: Array[Vector2i] = []
	for x in range(map_width):
		var transformed_noise := height_noise.get_noise_1d(x) * 0.5 + 1.0
		var height := int(
			transformed_noise * (maximum_height - minimum_height) + minimum_height
		)
		for y in range(height):
			ground_cells.append(Vector2i(x, -y))
		surface_tiles.append(Vector2i(x, -height))
	
	ground_tiles.set_cells_terrain_connect(ground_cells, 0, 0)


func _generate_background() -> void:
	# x: start index of surface tiles, y: end index (inclusive)
	
	var last_tree_x := -1
	for range in flat_surface_ranges:
		var length = range.y - range.x + 1
		for tile_index in range(range.x, range.y + 1):
			var tile := surface_tiles[tile_index]
			if randf() < TREE_PROBABILITY:
				if tile_index != range.x and tile_index != range.y and tile.x >= last_tree_x + 3:
					background_tiles.set_cell(tile + Vector2i.UP, BackgroundTile.TREE, Vector2i.ZERO)
					last_tree_x = tile.x
			
			if randf() < GRASS_PROBABILITY:
				background_tiles.set_cell(tile, BackgroundTile.GRASS, Vector2i.ZERO)


func _find_flat_surface_ranges() -> void:
	var surface_start := 0
	var new_surface_flag := true
	for tile_index in range(1, surface_tiles.size() - 1):
		var tile := surface_tiles[tile_index]
		var flat := _surface_tile_is_flat(tile)
		if flat and new_surface_flag:
			new_surface_flag = false
			surface_start = tile_index
		elif not flat and not new_surface_flag:
			flat_surface_ranges.append(Vector2i(surface_start, tile_index - 1))
			new_surface_flag = true


func _spawn_creatures() -> void:
	for surface_tile in surface_tiles:
		for creature_index in range(creatures.size()):
			var spawn_probability = creature_spawn_probabilities[creature_index]
			var require_flat := creature_flat_surface_required[creature_index]
			if not randf() < spawn_probability:
				continue
			if require_flat and not _surface_tile_is_flat(surface_tile):
				continue
			var creature = creatures[creature_index].instantiate()
			creature.position = _get_ground_position(surface_tile)
			$Creatures.add_child(creature)


func _surface_tile_is_flat(tile: Vector2i) -> bool:
	return ground_tiles.get_cell_atlas_coords(
		tile + Vector2i.DOWN
	) == FLAT_TILE_ATLAS_COORDS


func _get_ground_position(tile: Vector2i) -> Vector2:
	var tile_center = ground_tiles.map_to_local(tile)
	return tile_center + Vector2.DOWN * 0.5 * TILE_SIZE


func _spawn_player() -> void:
	@warning_ignore("integer_division")
	var center_tile := surface_tiles[surface_tiles.size() / 2]
	var center_position := _get_ground_position(center_tile)
	
	var ship: Node2D = return_ship_scene.instantiate()
	ship.position = center_position
	add_child(ship)
	
	var player: Node2D = player_scene.instantiate()
	player.position = center_position
	player.net_thrown.connect(add_projectile)
	add_child(player)
