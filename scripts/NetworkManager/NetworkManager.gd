extends Node

signal client_connected(peer_id: int)
signal client_disconnected(peer_id: int)
signal connected_to_server
signal connected_to_server_failed
signal server_disconnected

const PORT = 7100
const Default_server_ip: String = "192.168.9.22"
var Max_player: int = 100

# Player info
var players: Dictionary = {}

func _ready() -> void:
	multiplayer.peer_connected.connect(_client_connected)
	multiplayer.peer_disconnected.connect(_client_disconnected)
	multiplayer.connected_to_server.connect(_client_connected_to_server)
	multiplayer.connection_failed.connect(_client_connected_to_server_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)

# Create server
func _create_server() -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, Max_player)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	players[1] = {
		"Name": "Host",
		"Head": 0,
		"Face": 0,
		"Color": Color(1, 1, 1),
		"Ready": true,
		"Health": 100
	}
	print("HOST!!")
	return OK

# Create client
func _create_client(address: String = "") -> void:
	var peer = ENetMultiplayerPeer.new()
	if address.is_empty():
		address = "localhost"
	peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = peer

# Player connected
func _client_connected(peer_id: int) -> void:
	if !multiplayer.is_server(): return
	print("Adding player with ID: ", peer_id)  # Debug print
	players[peer_id] = {
		"Name": str(peer_id),
		"Head": 0,
		"Face": 0,
		"Color": Color(1, 1, 1),
		"Ready": false,
		"Health": 100
	}
	_sync_player_info.rpc(players)
	client_connected.emit(peer_id)

# Player disconnected
func _client_disconnected(peer_id: int) -> void:
	if !multiplayer.is_server(): return
	players.erase(peer_id)
	_sync_player_info.rpc(players)
	client_disconnected.emit(peer_id)

# Sync player info
@rpc("authority", "reliable")
func _sync_player_info(new_info: Dictionary) -> void:
	players = new_info
	print("Synced players: ", players)  # Debug print

# Load game scene
@rpc("call_local", "reliable")
func _load_game(game_scene_path: String) -> void:
	get_tree().change_scene_to_file(game_scene_path)


#Client_connected_to_server | only cilent emit
func _client_connected_to_server() -> void:
	print("Peer ID :", multiplayer.get_unique_id(), "connected to server")
	connected_to_server.emit()


#Client_connected_failed
func _client_connected_to_server_failed() -> void:
	multiplayer.multiplayer_peer = null
	print("Can't connected to server")
	connected_to_server_failed.emit()


#Server disconnected
func _server_disconnected() -> void:
	players.clear()
	for target_peer :int in players.keys():
		_sync_player_info.rpc_id(target_peer, players)
	multiplayer.multiplayer_peer = null
	print("SERRVER DISCONNECTED")
	server_disconnected.emit()


#func set_player_data(key: String, data):
	#players[key] = data

# When the server decides to start the game from a UI scene,
# do NetworkManager.load_game.rpc(filepath)
