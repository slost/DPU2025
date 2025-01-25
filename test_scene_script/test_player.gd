extends Sprite2D

@export var face_sprite :Sprite2D
@export var head_sprite :Sprite2D

func _cosmetic(head :int, face :int ,color :Color) -> void:
	face_sprite.frame = face
	head_sprite.frame = head
	$".".self_modulate = color
