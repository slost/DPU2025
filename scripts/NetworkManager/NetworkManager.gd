extends Node


signal client_connected(peer_id :int)
signal client_disconnected(peer_id :int)
signal connected_to_server
signal connected_to_server_failed
signal server_disconnected


const PORT = 7100
const Defult_server_ip :String = "192.168.9.22"
var Max_player :int = 100

#plaeyr info
var players :Dictionary


func _ready() -> void:
	multiplayer.peer_connected.connect(_client_connected) #client connected
	multiplayer.peer_disconnected.connect(_client_disconnected) #client disconnected
	multiplayer.connected_to_server.connect(_client_connected_to_server) #client connected to server
	multiplayer.connection_failed.connect(_client_connected_to_server_failed) #client connected falied
	multiplayer.server_disconnected.connect(_server_disconnected) #sever down


#Create server
func _create_server() -> Error:
	var peer :ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error :Error = peer.create_server(PORT, Max_player)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	players[1] = {
		"Name" : "Host", 
		"Head" : 0, 
		"Face" : 0, 
		"Color" : Color(0, 0, 0), 
		"Ready" : true, 
	}
	print("HOST!!")
	return OK

#Create clients
func _create_client(address :String = "") -> void:
	var peer :ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	if address.is_empty():
		address = Defult_server_ip
	peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = peer
	

#Player connected | only host signal
func _client_connected(peer_id :int)  -> void:
	if !multiplayer.is_server(): return
	
	await get_tree().create_timer(0.1).timeout
	players[peer_id] = {
		"Name" : str(peer_id), 
		"Head" : 0, 
		"Face" : 0, 
		"Color" : Color(0, 0, 0), 
		"Ready" : false, 
	}
	
	#sync_player_info
	for peer :int in players.keys():
		if peer != 1:
			_sync_player_info.rpc_id(peer, players)
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	client_connected.emit(peer_id)
	print("CLIENT ND ID :", peer_id)


#connected_to_server | host only read
func _client_disconnected(peer_id :int) -> void:
	if !multiplayer.is_server(): return
	
	await get_tree().create_timer(0.2).timeout
	
	if players.has(peer_id): players.erase(peer_id)
	
	for target_peer :int in players.keys():
		if target_peer != 1:
			_sync_player_info.rpc_id(target_peer, players)
	client_disconnected.emit(peer_id)


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


#Sync
#sync_player_data
@rpc("authority", "reliable")
func _sync_player_info(new_info :Dictionary) -> void:
	players = new_info


#func set_player_data(key: String, data):
	#players[key] = data

# When the server decides to start the game from a UI scene,
# do NetworkManager.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func _load_game(game_scene_path :String) -> void:
	await get_tree().physics_frame
	get_tree().change_scene_to_file(game_scene_path)
