extends Node2D

@export var ip_adress :TextEdit
@export var b_host :Button
@export var b_join :Button
@export var b_play :Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Title
	
	
	#Lobby
	NetworkManager.client_connected.connect(_client_connected)
	NetworkManager.client_disconnected.connect(_client_disconnected)
	NetworkManager.connected_to_server.connect(_connected_to_server)
	NetworkManager.connected_to_server_failed.connect(_connected_to_server_failed)
	NetworkManager.server_disconnected.connect(_server_disconnected)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_b_host_pressed() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
	NetworkManager._create_server()
	


func _on_b_join_pressed() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
		print("Connecting...")
		await get_tree().create_timer(0.5).timeout
	NetworkManager._create_client(ip_adress.text)

#Lobby
func _client_connected(peer_id :int) -> void:
	print("CLIENT ID:",peer_id, "Connected")

func _client_disconnected(peer_id :int) -> void:
	print("CLIENT ID:", peer_id, "Disconnected")

func _connected_to_server() -> void:
	print("connected to server!!")

func _connected_to_server_failed() -> void:
	print("Connected tp server failed")

func _server_disconnected() -> void:
	print("server disconnected")
