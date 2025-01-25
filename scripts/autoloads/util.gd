extends Node

var lv_ents = Refs.ZLevel.Entities

func move_entity(entity, from: Vector2i, to: Vector2i) -> void:
	Refs.ents.erase_cell(from)
	Refs.ents.set_cell(to, lv_ents, entity)

