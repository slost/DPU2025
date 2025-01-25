extends Sprite2D

@export var face_sprite: Sprite2D
@export var head_sprite: Sprite2D
@export var area_player: Area2D

var health: int = 100

func _ready() -> void:
	area_player.connect("area_entered", Callable(self, "_on_area_player_area_entered"))

func _on_area_player_area_entered(area: Area2D) -> void:
	if area.is_in_group("players"):
		area.get_parent().take_damage(10)

func take_damage(damage: int) -> void:
	if multiplayer.is_server():
		health -= damage
		if health <= 0:
			print("Player defeated!")
			# Handle player defeat logic here
