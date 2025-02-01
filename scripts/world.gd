extends Node
class_name World

@export var size: Vector2i = Vector2i(10, 10)
@export var player_amount: int = 5
@export var tile_map: TileMapLayer

var grid: Array = []
var grid_width: int
var grid_height: int
var shrink_times: int = 0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	var world_cells = WorldCellSize(player_amount)
	generate_map(world_cells.x, world_cells.y)
	spawn_player()

func WorldCellSize(_player_amount: int) -> Vector2i:
	var chunk_size = Vector2i(9, 9)
	return _player_amount * chunk_size * 2

func generate_map(width: int, height: int) -> void:
	grid_width = width
	grid_height = height
	var cell_data = {
		"Floor": 0,
		"Entity": null
	}
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			grid[i].append(cell_data)
	size = Vector2i(width, height)
	draw_map()

func shrink_map() -> void:
	var empty_atlas = Vector2i(2, 0)
	for i in range(size.x - shrink_times):
		for j in range(size.y - shrink_times):
			if i == 0 or i == size.x - 1 or j == 0 or j == size.y - 1:
				tile_map.set_cell(Vector2i(i + shrink_times, j + shrink_times), 0, empty_atlas)
			if i == size.x - shrink_times - 1 or j == size.y - shrink_times - 1:
				tile_map.set_cell(Vector2i(i, j), 0, empty_atlas)
	shrink_times += 1

func draw_map() -> void:
	for _x in range(size.x):
		for _y in range(size.y):
			var coords = Vector2i(_x, _y)
			if (_x + _y) % 2 == 0:
				tile_map.set_cell(coords, 0, Vector2(0, 0))
			else:
				tile_map.set_cell(coords, 0, Vector2(1, 0))

func spawn_player() -> void:
	var chunk_size = Vector2i(8, 8)
	var player_chunks = Vector2i(rng.randi_range(0, get_chunk_amount().x), rng.randi_range(0, get_chunk_amount().y))
	var position_in_chunk = Vector2i(rng.randi_range(0, chunk_size.x), rng.randi_range(0, chunk_size.y))
	var global_position = player_chunks * chunk_size + position_in_chunk
	print("Player spawned at:", global_position)

func get_chunk_amount() -> Vector2i:
	return size / Vector2i(8, 8)

func _on_timer_timeout() -> void:
	shrink_map()
