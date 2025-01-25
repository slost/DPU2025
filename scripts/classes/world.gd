extends Node
class_name World

# Size of the world map
@export var size: Vector2i = Vector2i(10, 10)
@export var player_amount: int = 5
@export var tile_map: TileMapLayer

var grid = [] # 2D array to store the map
var grid_width: int
var grid_height: int

var rng = RandomNumberGenerator.new()

var players: Array = []



func _ready() -> void:
    var world_cells = WorldCellSize(player_amount)
    generate_map(world_cells.x, world_cells.y)
    spawn_player()
    print("Size" + str(size))
    Global.world = self

func WorldCellSize(_player_amount: int) -> Vector2i:
    var chunk_size = Vector2i(9, 9)
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
func generate_map(width, height) -> void:
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



func draw_map() -> void:
    for _x in range(size.x):
        for _y in range(size.y):
            var coords = Vector2i(_x, _y)
            if (_x + _y) % 2 == 0:
                tile_map.set_cell(coords, 0, Vector2(0, 0))  # Tile at (0, 0)
            else:
                tile_map.set_cell(coords, 0, Vector2(1, 0))  # Tile at (0, 1)

func get_chunk_amount() -> Vector2i:
    return size / Vector2i(8, 8)


# Spawning the player by random location
func spawn_player() -> void:
    # Randomize the player position by the chunk (9x9)
    var chunk_size = Vector2i(8, 8)
    var player_chunks: Vector2i = Vector2i(rng.randi_range(0, get_chunk_amount().x), rng.randi_range(0, get_chunk_amount().y))
    var position_in_chunk: Vector2i = Vector2i(rng.randi_range(0, chunk_size.x), rng.randi_range(0, chunk_size.y))
    var inst_player = Player.new()
    

    inst_player.starting_chunk = player_chunks
    print(position_in_chunk)
    var global_position = player_chunks * chunk_size + position_in_chunk
    inst_player.position = global_position
    players.append(inst_player)
    grid[global_position.x][global_position.y]["Entity"] = inst_player
    print("Test:" + str(grid[global_position.x][global_position.y]["Entity"]))
    add_child(inst_player)
    print(players[0])
    
func set_cell(position: Vector2i, data: Dictionary) -> void:
    var cell = grid[position.x][position.y]
    for i in cell.keys():
        if data.has(i):
            cell[i] = data[i]


func generate_player(player_id) -> void:
    pass

    # Generate the player
    # Randomize the bubble position





