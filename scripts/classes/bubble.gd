extends Node
class_name Bubble

var body: Array = []
var direction: Vector2i = Vector2i.RIGHT
var speed: float = 1
var head_position: Vector2i = Vector2i(0, 0)

var lv_ents = Refs.ZLevel.Entities



func _init() -> void:
    print(self)

func create_body() -> void:
    for i in range(3):
        var new_body = Body.new()
        body.append(new_body)
        var body_coords = head_position - direction * (i + 1)
        Refs.ents.set_cell(body_coords, 1, Refs.enitities_atlas["Body"])
        print("Body created at: " + str(body_coords))
        new_body.position = body_coords

func move() -> void:
    var map: TileMapLayer = Refs.map

    # Move Head
    var head_pos = head_position
    Refs.ents.set_cell(head_pos, lv_ents, Vector2(0, 0))
    # Pararellel to the opposite of the map when the snake hits the wall    
    if head_pos.x == 0 and direction == Vector2i.LEFT:
        head_pos = Vector2i(map.size.x - 1, head_pos.y)
    elif head_pos.x == map.size.x - 1 and direction == Vector2i.RIGHT:
        head_pos = Vector2i(0, head_pos.y)
    elif head_pos.y == 0 and direction == Vector2i.UP:
        head_pos = Vector2i(head_pos.x, map.size.y - 1)
    elif head_pos.y == map.size.y - 1 and direction == Vector2i.DOWN:
        head_pos = Vector2i(head_pos.x, 0)
    else:
        head_position += direction
    Refs.ents.set_cell(head_pos, lv_ents, Refs.enitities_atlas["Head"])

    # Move Body
    for i in range(body.size()):
        var body_pos = body[i].position
        Refs.ents.set_cell(body_pos, lv_ents, Vector2(0, 0))
        if i == 0:
            body[i].position = head_pos
        else:
            body[i].position = body[i - 1].position
        Refs.ents.set_cell(body[i].position, lv_ents, Refs.enitities_atlas["Body"])