extends TileMapLayer

@export var size: Vector2 = Vector2(7, 5)

@export var start_coords: Vector2 = Vector2(0, 0)

func _ready() -> void:
    Refs.map = self

func get_size() -> Vector2:
    return size

func set_size(new_size: Vector2) -> void:
    size = new_size
    update_map()

func update_map() -> void:
    pass

