extends Node

var ents: Node
var map: Node


var tile_size: int = 128


var enitities_atlas = {
    "Head" : Vector2i(2, 0),
    "Minion" : Vector2i(3, 0),
    "Natural Bubble" : Vector2i(0, 1),
}

enum ZLevel {
    Background,
    Entities,
}

enum Position {
    Middle,
}
