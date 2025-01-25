extends Node2D

@export var player_spawner: NodePath
@export var hit_detector: NodePath
@export var game_state: NodePath

@export var speed_multiplier: float = 0.5

# Multiplayer
@export var player_instance: PackedScene
@export var anim_game_original: AnimatedSprite2D

@export var time_text: Label

@export var player_container: Node2D
@export var _time: Timer

var is_pause: bool = false

# Players info
var players_info: Dictionary = {}

# Time
var time_level: int

# Input
var can_input: bool

func _ready() -> void:
	_time.start()  
	can_input = true 
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.2).timeout

	NetworkManager.client_connected.connect(_client_connected)
	NetworkManager.client_disconnected.connect(_client_disconnected)
	NetworkManager.server_disconnected.connect(_server_disconnected)

	if multiplayer.is_server():
		# Ensure the player_spawner node is valid
		var spawner = get_node(player_spawner)
		if spawner:
			spawner.spawn_players()
		else:
			print("Error: PlayerSpawner node not found!")

		# Ensure the hit_detector node is valid
		var detector = get_node(hit_detector)
		if detector:
			detector.connect("player_hit", Callable(get_node(game_state), "update_health"))
		else:
			print("Error: HitDetector node not found!")

#Input
func _input(event: InputEvent) -> void:
	if !can_input: return
	if event.is_action_pressed("left"):
		_on_player_input_left(multiplayer.get_unique_id(), "left")
	elif event.is_action_pressed("right"):
		_on_player_input_right(multiplayer.get_unique_id(), "right")
	elif event.is_action_pressed("up"):
		_on_player_input_up(multiplayer.get_unique_id(), "up")
	elif event.is_action_pressed("down"):
		_on_player_input_down(multiplayer.get_unique_id(), "down")
	elif event.is_action_pressed("stop"):
		_on_player_input_stop(multiplayer.get_unique_id(), "stop")

#pro
func _physics_process(delta: float) -> void:
	time_text.text = str(time_level)

#Player inputing
func _on_player_input_left(peer_id: int, direction: String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)

func _on_player_input_right(peer_id: int, direction: String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)

func _on_player_input_up(peer_id: int, direction: String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)

func _on_player_input_down(peer_id: int, direction: String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)

func _on_player_input_stop(peer_id: int, direction: String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)

#player movement
func _player_movement(peer_id: int, direction: String) -> void:
	if multiplayer.is_server():
		if player_container.get_node_or_null(str(peer_id)) and players_info.has(peer_id):  # Check if the key exists
			players_info[peer_id]["Direction"] = direction
			_anim_direction.rpc(peer_id, direction)
			_sync_player_info.rpc(players_info)
	else:
		_request_player_movement.rpc_id(1, peer_id, direction)

@rpc("any_peer", "reliable")
func _request_player_movement(peer_id: int, direction: String) -> void:
	if player_container.get_node_or_null(str(peer_id)) and players_info.has(peer_id):  # Check if the key exists
		players_info[peer_id]["Direction"] = direction
		_anim_direction.rpc(peer_id, direction)
		_sync_player_info.rpc(players_info)

@rpc("authority", "reliable", "call_local")
func _move_player(player_id: int, direction: String, distance: int) -> void:
	var direction_all: Dictionary = {
		"left": Vector2(-distance, 0), 
		"right": Vector2(distance, 0), 
		"up": Vector2(0, -distance), 
		"down": Vector2(0, distance), 
		"stop": Vector2(0, 0), 
	}

	# Check if the direction is valid
	if direction in direction_all:
		var player_node = player_container.get_node_or_null(str(player_id))
		if player_node:
			player_node.position += direction_all[direction]
			_checking_hitting()
		else:
			print("Error: Player with ID ", player_id, " not found.")
	else:
		print("Error: Invalid direction '", direction, "'.")

func _checking_hitting() -> void:
	if !multiplayer.is_server(): return
	var hitting: Array
	for player_id: int in players_info.keys():
		if players_info[player_id]["Hitting"] != false:
			hitting.append(player_id)
	print("Hitting :", hitting)

#Animation direction
@rpc("authority", "reliable", "call_local")
func _anim_direction(peer_id: int, direction: String) -> void:
	var player_node = player_container.get_node_or_null(str(peer_id))
	if player_node:
		var anim_node = player_node.get_node_or_null(str(peer_id) + "_anim")
		if anim_node:
			anim_node.play(str(direction))

#Spawn player
@rpc("authority", "reliable", "call_local")
func _spawn_player(peer_id: int) -> void:
	var player: Sprite2D = player_instance.instantiate() as Sprite2D
	var player_face: int = NetworkManager.players[peer_id]["Face"]
	player.name = str(peer_id)
	player._cosmetic(NetworkManager.players[peer_id]["Head"], NetworkManager.players[peer_id]["Face"], NetworkManager.players[peer_id]["Color"])
	player_container.add_child(player, true)
	player.visible = true  # Ensure the player is visible

#Duplicate anim
@rpc("authority", "reliable", "call_local")
func _duplicate_anim(peer_id: int) -> void:
	var anim_dup: AnimatedSprite2D = anim_game_original.duplicate()
	anim_dup.visible = true
	anim_dup.name = str(peer_id) + "_anim"
	anim_dup.position.x += 0.0
	anim_dup.position.y += 10.0
	if player_container.get_node_or_null(str(peer_id)):
		player_container.get_node_or_null(str(peer_id)).add_child(anim_dup, true)

func _client_connected(peer_id: int) -> void:
	print("CLIENT ID:", peer_id, "Connected")
	
	# Add the player to players_info
	players_info[peer_id] = {
		"Direction": "stop",  # Default direction
		"Hitting": false      # Default hitting state
	}
	
	# Spawn the player
	_spawn_player(peer_id)
	
	# Sync player info with all clients
	_sync_player_info.rpc(players_info)

func _client_disconnected(peer_id: int) -> void:
	print("CLIENT ID:", peer_id, "Disconnected")
	
	# Remove the player from players_info
	if players_info.has(peer_id):
		players_info.erase(peer_id)
	
	# Clean up the player node
	_clean_node.rpc(peer_id)
	
	# Sync player info with all clients
	_sync_player_info.rpc(players_info)

func _server_disconnected() -> void:
	print("server disconnected")

#Clean node
@rpc("authority", "reliable", "call_local")
func _clean_node(peer_id) -> void:
	if player_container.get_node_or_null(str(peer_id)):
		player_container.get_node_or_null(str(peer_id)).queue_free()

#Sync ////////////////////////////////////////////
#sync player info
@rpc("authority", "reliable")
func _sync_player_info(new_info: Dictionary) -> void:
	players_info = new_info

#sync_time_level
@rpc("authority", "reliable")
func _sync_time_level(new_time: int) -> void:
	time_level = new_time

#sync_input
@rpc("authority", "reliable")
func _sync_can_input(can: bool) -> void:
	can_input = can

func _on_timer_timeout() -> void:
	if !multiplayer.is_server(): return

	time_level += 1

	# Allow movement every 3 seconds
	if time_level % 3 == 0:  # Check if time_level is a multiple of 3
		for player_id in players_info.keys():
			if players_info.has(player_id):  # Check if the key exists
				# Move players based on their current direction
				_move_player.rpc(player_id, players_info[player_id]["Direction"], 64)
		
		# Reset player directions to "stop" after moving
		for player_id in players_info.keys():
			if players_info.has(player_id):  # Check if the key exists
				players_info[player_id]["Direction"] = "stop"
				_anim_direction.rpc(player_id, "stop")
		
		# Sync player info after movement
		_sync_player_info.rpc(players_info)

	# Sync the time level with all clients
	_sync_time_level.rpc(time_level)

@rpc("authority", "reliable", "call_local")
func _take_damage(peer_id: int) -> void:
	var player_hitting: Array
	player_hitting.append(peer_id)
	print(player_hitting)
