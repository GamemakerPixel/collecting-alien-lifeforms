extends Node2D


@export_category("Generation Noise")
@export var height_noise: Noise # Only x axis used

@export_category("Generation Parameters")
@export var map_width: int = 1000 # This will be obsolete with an unlimited chunking system.
@export var minimum_height: int = 1
@export var maximum_height: int = 15

@export_category("Tiles")
@export var ground_tiles: TileMapLayer


func _ready() -> void:
	_randomize_noise()
	_generate_ground()


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
	
	ground_tiles.set_cells_terrain_connect(ground_cells, 0, 0)
