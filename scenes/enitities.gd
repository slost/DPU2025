extends TileMapLayer

@onready var map: TileMapLayer = %Map

var ents_lv = 1

var snake = Snake.new()

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
    snake.head_position = starting_pos
    print("Starting position set to: " + str(starting_pos))
    snake.create_body()
    update_graphics()

func move_snake() -> void:
    snake.move()
    update_graphics()

func update_graphics() -> void:
    %Head.position = snake.head_position * Refs.tile_size + Vector2i(64, 64)
    var snake_dir: Vector2 = snake.direction
    if snake.direction == Vector2i.UP or snake.direction == Vector2i.DOWN:
        %Head.rotation = snake_dir.angle_to(Vector2.LEFT)
    else: # LEFT or RIGHT
        %Head.rotation = snake_dir.angle_to(Vector2.RIGHT)


func create_body() -> void:
    return
    var body = snake.body
    for i in range(body.size()):
        var body_coords = snake.head_position - snake.direction * (i + 1)
        set_cell(body_coords, ents_lv, Refs.enitities_atlas["Body"])
        print("Body created at: " + str(body_coords))


func _input(event):
    var direction: Vector2i = snake.direction
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
                KEY_1:
                    create_body()
            if direction == -snake.direction:
                return
            snake.direction = direction

            print("Direction set to: " + str(snake.direction))
            update_graphics()

