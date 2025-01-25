extends TileMapLayer

@onready var map: TileMapLayer = %Map

var ents_lv = 1

var bubble = Bubble.new()

func _ready() -> void:
	Refs.ents = self

func set_starting_position(target_position: int) -> void:
	var size = map.size
	var starting_pos: Vector2i
	match target_position:
		Refs.Position.Middle:
			starting_pos = Vector2i(int(size.x / 2), int(size.y / 2))
		_:
			starting_pos = Vector2i(0, 0)
	set_cell(starting_pos, ents_lv, Refs.enitities_atlas["Head"])
	bubble.head_position = starting_pos
	print("Starting position set to: " + str(starting_pos))
	bubble.create_minions()
	update_graphics()

func move_bubble() -> void:
	bubble.move()
	update_graphics()

func update_graphics() -> void:
	%Head.position = bubble.head_position * Refs.tile_size + Vector2i(64, 64)
	var bubble_dir: Vector2 = bubble.direction
	if bubble.direction == Vector2i.UP or bubble.direction == Vector2i.DOWN:
		%Head.rotation = bubble_dir.angle_to(Vector2.LEFT)
	else: # LEFT or RIGHT
		%Head.rotation = bubble_dir.angle_to(Vector2.RIGHT)


func create_minion() -> void:
	return
	var minion = bubble.minions
	for i in range(minion.size()):
		var minion_coords = bubble.head_position - bubble.direction * (i + 1)
		set_cell(minion_coords, ents_lv, Refs.enitities_atlas["Minion"])
		print("Body created at: " + str(minion_coords))


func _input(event):
	var direction: Vector2i = bubble.direction
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_UP:
					direction = Vector2i.UP
				KEY_DOWN:
					direction = Vector2i.DOWN
				KEY_LEFT:
					direction = Vector2i.LEFT
				KEY_RIGHT:
					direction = Vector2i.RIGHT
			bubble.direction = direction

			print("Direction set to: " + str(bubble.direction))
			update_graphics()
