extends Node
class_name Bubble

var minions: Array = []
var direction: Vector2i = Vector2i.RIGHT
var speed: float = 1
var head_position: Vector2i = Vector2i(0, 0)

var lv_ents = Refs.ZLevel.Entities


func _init() -> void:
	print(self)


func create_minions() -> void:
	# Create 4 mionions aroud the head (4 directions: Top, Right, Bottom, Left)
	var dir: Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	for i in range(4):
		minions.append(Minion.new())
		minions[i].position = dir[i]
		minions[i].global_position = head_position + dir[i]
		Refs.ents.set_cell(minions[i].global_position, lv_ents, Refs.enitities_atlas["Minion"])
	



func game_over() -> void:
	print("Game Over")

func move() -> void:
	var map: TileMapLayer = Refs.map

	# Move Head
	Util.move_entity(Refs.enitities_atlas["Head"], head_position, head_position + direction)

	# Game Over when the bubble hits the wall
	if head_position.x == 0 and direction == Vector2i.LEFT:
		game_over()
	elif head_position.x == map.size.x - 1 and direction == Vector2i.RIGHT:
		game_over()
	elif head_position.y == 0 and direction == Vector2i.UP:
		game_over()
	elif head_position.y == map.size.y - 1 and direction == Vector2i.DOWN:
		game_over()

	head_position += direction
	# Refs.ents.set_cell(head_position, lv_ents, Refs.enitities_atlas["Head"])

	move_moinions()



func move_moinions() -> void:
	# Move minions
	for i in range(minions.size()):
		var minions_pos: Vector2i = minions[i].position
		var destination: Vector2i = head_position + minions_pos
		
		Util.move_entity(Refs.enitities_atlas["Minion"], minions[i].global_position, destination)
		minions[i].global_position = destination
