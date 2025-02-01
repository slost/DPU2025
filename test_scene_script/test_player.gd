extends Sprite2D

@export var face_sprite: Sprite2D
@export var head_sprite: Sprite2D
@export var area_player: Area2D
@export var bullet_scene: PackedScene  # Export the Bullet scene here

var shoot_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	pass

func _cosmetic(head: int, face: int, color: Color) -> void:
	face_sprite.frame = face
	head_sprite.frame = head
	$".".self_modulate = color

func _my_peer_id() -> int:
	return multiplayer.get_unique_id()

func shoot() -> void:
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.direction = shoot_direction
		bullet.position = position  # Spawn bullet at player's position
		get_parent().add_child(bullet)  # Add bullet to the game world
