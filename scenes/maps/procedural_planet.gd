extends Map

const TILE_SIZE = 32

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

@export_category("Tiles")
@export var ground_tiles: TileMapLayer

var surface_tiles: Array[Vector2i] = []


func _ready() -> void:
	super._ready()
	_randomize_noise()
	_generate_ground()
	_spawn_creatures()
	_spawn_player()


func _randomize_noise() -> void:
	height_noise.seed = randi()


func _generate_ground() -> void:
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


func _spawn_creatures() -> void:
	for surface_tile in surface_tiles:
		for creature_index in range(creatures.size()):
			var spawn_probability = creature_spawn_probabilities[creature_index]
			if not randf() < spawn_probability:
				continue
			var creature = creatures[creature_index].instantiate()
			creature.position = _get_ground_position(surface_tile)
			$Creatures.add_child(creature)


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
	add_child(player)
