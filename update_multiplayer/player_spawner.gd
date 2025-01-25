extends Node2D

@export var player_scene: PackedScene
@export var spawn_points: Array[Vector2] = [Vector2(0, 0), Vector2(100, 100)]  # Default spawn points

func _ready() -> void:
	if multiplayer.is_server():
		spawn_players()

func spawn_players() -> void:
	if player_scene == null:
		print("Error: player_scene is not assigned!")
		return
	if spawn_points.is_empty():
		print("Error: spawn_points is empty!")
		return

	print("Spawning players at positions:", spawn_points)
	for player_id in NetworkManager.players.keys():
		spawn_player(player_id)

func spawn_player(player_id: int) -> void:
	if player_scene == null:
		print("Error: player_scene is not assigned!")
		return
	if spawn_points.is_empty():
		print("Error: spawn_points is empty!")
		return

	var player = player_scene.instantiate()
	if player == null:
		print("Error: Failed to instantiate player_scene!")
		return

	player.name = str(player_id)
	player.position = spawn_points[player_id % spawn_points.size()]
	$Players_container.add_child(player)  # Add player to Players_container
