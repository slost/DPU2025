extends Sprite2D


@export var face_sprite :Sprite2D
@export var head_sprite :Sprite2D
@export var area_player :Area2D


func _ready() -> void:
	pass


func _cosmetic(head :int, face :int ,color :Color) -> void:
	face_sprite.frame = face
	head_sprite.frame = head
	$".".self_modulate = color




func _on_area_player_area_entered(area: Area2D) -> void:
	if area.is_in_group("players"):
		print("IS IN GROUP")
		area._on_area_attack()


func _on_area_attack() -> void:
	if multiplayer.is_server():
		print("FROM SERVER")
	else:
		print("FROM CLIENT")
