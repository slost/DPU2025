extends Node2D

@export var speed_multiplier: float = 0.5

#multiplayer //////////////////
@export var player_instance :PackedScene

@export var player_container :Node2D

#//////////////////////////////

@onready var map: TileMapLayer = $Map
@onready var ents: TileMapLayer = $Enitities

var tiks: int = 0
var current_moves: int = 0
var current_speed: float = 1


var is_pause: bool = false

#players info
var players_info :Dictionary

func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.2).timeout
	
	NetworkManager.client_connected.connect(_client_connected)
	NetworkManager.client_disconnected.connect(_client_disconnected)
	NetworkManager.server_disconnected.connect(_server_disconnected)
	
	if multiplayer.is_server():
		for player_id :int in NetworkManager.players.keys():
			players_info[player_id] = {
				"Name" : NetworkManager.players[player_id]["Name"], 
				"Minion" : 4, "Direction" : "", "Position" : Vector2()
			}
			
			#sync plaeyr info
			if player_id != 1:
				_sync_player_info.rpc_id(player_id, players_info)
			await get_tree().create_timer(0.1).timeout
			_spawn_player.rpc(player_id)
			
	#draw_map()

#Input
func _input(event: InputEvent) -> void:
	#Debuging
	if event.is_action_pressed("ui_cancel"):
		print(players_info)
		print(player_container.get_node_or_null(str(multiplayer.get_unique_id())).position)
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


#Player inputing
func _on_player_input_left(peer_id :int, direction :String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)


func _on_player_input_right(peer_id :int, direction :String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)


func _on_player_input_up(peer_id :int, direction :String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)


func _on_player_input_down(peer_id :int, direction :String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)


func _on_player_input_stop(peer_id :int, direction :String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)


#player movement
func _player_movement(peer_id :int, direction :String) -> void:
	if multiplayer.is_server():
		if player_container.get_node_or_null(str(peer_id)):
			players_info[peer_id]["Direction"] = direction
			_sync_player_info.rpc(players_info)
	else:
		_request_player_movement.rpc_id(1, peer_id, direction)


@rpc("any_peer", "reliable", "call_local")
func _request_player_movement(peer_id :int, direction :String) -> void:
	if player_container.get_node_or_null(str(peer_id)):
		players_info[peer_id]["Direction"] = direction
		_sync_player_info.rpc(players_info)


@rpc("authority", "reliable", "call_local")
func _move_player(player_id: int, direction: String, distanc: int) -> void:
	var direction_all: Dictionary = {
		"left": Vector2(-distanc, 0), 
		"right": Vector2(distanc, 0), 
		"up": Vector2(0, -distanc), 
		"down": Vector2(0, distanc), 
		"stop": Vector2(0, 0), 
	}

	# Check if the direction is valid
	if direction in direction_all:
		var player_node = player_container.get_node_or_null(str(player_id))
		if player_node:
			player_node.position += direction_all[direction]
		else:
			print("Error: Player with ID ", player_id, " not found.")
	else:
		print("Error: Invalid direction '", direction, "'.")


#Spawon player
@rpc("authority", "reliable", "call_local")
func _spawn_player(peer_id :int) -> void:
	var player :Sprite2D = player_instance.instantiate() as Sprite2D
	var plaeyr_face :int = NetworkManager.players[peer_id]["Face"]
	player.name = str(peer_id)
	player._cosmetic(NetworkManager.players[peer_id]["Head"], NetworkManager.players[peer_id]["Face"], NetworkManager.players[peer_id]["Color"])
	
	player_container.add_child(player, true)

#Duplicate anim
@rpc("authority", "reliable", "call_local")
func _duplicate_anim(peer_id :int) -> void:
	pass


func _client_connected(peer_id :int) -> void:
	print("CLIENT ID:",peer_id, "Connected")
	_spawn_player(peer_id)


func _client_disconnected(peer_id :int) -> void:
	print("CLIENT ID:", peer_id, "Disconnected")
	_clean_node.rpc(peer_id)


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
func _sync_player_info(new_info :Dictionary) -> void:
	players_info = new_info


#func _process(delta: float) -> void:
	#if is_pause:
		#return
#
	#tiks += 1
#
	#if tiks >= tik_per_move():
		#ents.move_bubble()
		#current_moves += 1
		#print("Moves:" + str(current_moves))
		#tiks = 0
		#
#
#
#func draw_map() -> void:
	#for x in range(map.get_size().x):
		#for y in range(map.get_size().y):
			#var coords = Vector2i(x, y)
			#if (x + y) % 2 == 0:
				#map.set_cell(coords, 0, Vector2(0, 0))  # Tile at (0, 0)
			#else:
				#map.set_cell(coords, 0, Vector2(1, 0))  # Tile at (0, 1)
	#ents.set_starting_position(Refs.Position.Middle)
#
#func tik_per_move() -> int:
	#var fps:int = 60
	#return int(fps / current_speed)


func _on_timer_timeout() -> void:
	if !multiplayer.is_server(): return
	for player_id :int in players_info.keys():
		_move_player.rpc(player_id, players_info[player_id]["Direction"], 64)
	for player_id :int in players_info.keys():
		players_info[player_id]["Direction"] = "stop"
		_sync_player_info.rpc(players_info)
	
