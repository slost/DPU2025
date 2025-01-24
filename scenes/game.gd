extends Node2D

@export var speed_multiplier: float = 0.5


@onready var map: TileMapLayer = $Map
@onready var ents: TileMapLayer = $Enitities

var tiks: int = 0
var current_moves: int = 0
var current_speed: float = 1


var is_pause: bool = false

func _ready() -> void:

	draw_map()

func _process(delta: float) -> void:
	if is_pause:
		return

	tiks += 1

	if tiks >= tik_per_move():
		ents.move_bubble()
		current_moves += 1
		print("Moves:" + str(current_moves))
		tiks = 0
		


func draw_map() -> void:
	for x in range(map.get_size().x):
		for y in range(map.get_size().y):
			var coords = Vector2i(x, y)
			if (x + y) % 2 == 0:
				map.set_cell(coords, 0, Vector2(0, 0))  # Tile at (0, 0)
			else:
				map.set_cell(coords, 0, Vector2(1, 0))  # Tile at (0, 1)
	ents.set_starting_position(Refs.Position.Middle)

func tik_per_move() -> int:
	var fps:int = 60
	return int(fps / current_speed)
