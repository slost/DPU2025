extends Node

var players_health: Dictionary = {}

func _ready() -> void:
	if multiplayer.is_server():
		for player_id in NetworkManager.players.keys():
			players_health[player_id] = 100

func update_health(player_id: int, damage: int) -> void:
	if multiplayer.is_server():
		players_health[player_id] -= damage
		if players_health[player_id] <= 0:
			players_health[player_id] = 0
			print("Player", player_id, "defeated!")
			check_game_over()

func check_game_over() -> void:
	var alive_players = 0
	for player_id in players_health.keys():
		if players_health[player_id] > 0:
			alive_players += 1
	if alive_players <= 1:
		print("Game Over!")
		# Transition back to the lobby or show game over screen
