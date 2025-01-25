extends Node
class_name World

# Size of the world map
@export var size: Vector2i = Vector2i(10, 10)
@export var player_amount: int = 5
@export var tile_map: TileMapLayer

var grid: Array = [] # 2D array to store the map
var grid_width: int
var grid_height: int
var shrink_times: int = 0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var players: Array = []



func _ready() -> void:
	var world_cells: Vector2i = WorldCellSize(player_amount)
	generate_map(world_cells.x, world_cells.y)
	spawn_player()
	print("Size" + str(size))

func WorldCellSize(_player_amount: int) -> Vector2i:
	var chunk_size: Vector2i = Vector2i(9, 9)
	return _player_amount * chunk_size * 2


enum WorldSize {
	VerySmall,
	Small,
	Medium,
	Large
}

enum Floor {
	Empty,
	Field,
}


# Generate the map
func generate_map(width: int, height: int) -> void:
	grid_width = width
	grid_height = height
	var cell_data: Dictionary = {
		"Floor" : Floor.Field,
		"Entity" : null
		}
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			grid[i].append(cell_data) # Set a starter value for each position
	print(grid[0][0]["Entity"])
	size = Vector2i(width, height)
	draw_map()

# shrink the map by removing the borders of the map closer to the center by set cell of the tile_map by
func shrink_map() -> void:
	var empty_atlas: Vector2i = Vector2i(2, 0)
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
			var coords: Vector2i = Vector2i(_x, _y)
			if (_x + _y) % 2 == 0:
				tile_map.set_cell(coords, 0, Vector2(0, 0))  # Tile at (0, 0)
			else:
				tile_map.set_cell(coords, 0, Vector2(1, 0))  # Tile at (0, 1)

func update_map() -> void:
	pass

func get_chunk_amount() -> Vector2i:
	return size / Vector2i(8, 8)


# Spawning the player by random location
func spawn_player() -> void:
	# Randomize the player position by the chunk (9x9)
	var chunk_size: Vector2i = Vector2i(8, 8)
	var player_chunks: Vector2i = Vector2i(rng.randi_range(0, get_chunk_amount().x), rng.randi_range(0, get_chunk_amount().y))
	var position_in_chunk: Vector2i = Vector2i(rng.randi_range(0, chunk_size.x), rng.randi_range(0, chunk_size.y))
	
	# Spawn Player
	# var inst_player = Player.new()
	

	# inst_player.starting_chunk = player_chunks
	# print(position_in_chunk)
	# var global_position = player_chunks * chunk_size + position_in_chunk
	# inst_player.position = global_position
	# players.append(inst_player)
	
	# grid[global_position.x][global_position.y]["Entity"] = inst_player
	# print("Test:" + str(grid[global_position.x][global_position.y]["Entity"]))
	# add_child(inst_player)
	# print(players[0])

    
func set_cell(position: Vector2i, data: Dictionary) -> void:
	var cell: Dictionary = grid[position.x][position.y]
	for i: int in cell.keys():
		if data.has(i):
			cell[i] = data[i]


# func generate_player(player_id) -> void:
# 	pass

	# Generate the player
	# Randomize the bubble position


func _on_timer_timeout() -> void:
	shrink_map()

# Use mouse wheel to scrolling the camera
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == 1:
			$Camera2D.offset += -event.relative / $Camera2D.zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$Camera2D.zoom /= 1.1
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$Camera2D.zoom *= 1.1