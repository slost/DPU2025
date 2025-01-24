extends Node

var ents: Node
var map: Node



var tile_size: int = 128


var enitities_atlas = {
    "Head" : Vector2i(2, 0),
    "Body" : Vector2i(3, 0),
}

enum ZLevel {
    Background,
    Entities,
}

enum Position {
    Middle,
}
