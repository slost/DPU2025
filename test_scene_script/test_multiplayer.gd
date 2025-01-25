extends Node2D

@export var ip_adress : TextEdit
@export var b_host : Button
@export var b_join : Button
@export var b_play : Button

var player_scene = preload("res://test_scene_script/test_player.gd")

func _ready() -> void:
	# Connect signals for multiplayer events
	NetworkManager.client_connected.connect(_client_connected)
	NetworkManager.client_disconnected.connect(_client_disconnected)
	NetworkManager.connected_to_server.connect(_connected_to_server)
	NetworkManager.connected_to_server_failed.connect(_connected_to_server_failed)
	NetworkManager.server_disconnected.connect(_server_disconnected)

	# Connect button signals
	b_host.pressed.connect(_on_b_host_pressed)
	b_join.pressed.connect(_on_b_join_pressed)
	b_play.pressed.connect(_on_b_play_pressed)

func _on_b_host_pressed() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
	NetworkManager._create_server()
	spawn_player()

func _on_b_join_pressed() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
		print("Connecting...")
		await get_tree().create_timer(0.5).timeout
	NetworkManager._create_client(ip_adress.text)

func _on_b_play_pressed() -> void:
	if multiplayer.is_server():
		spawn_player()

func spawn_player() -> void:
	var player = player_scene.instantiate()
	add_child(player)
	player.position = Vector2(randf_range(0, 1024), randf_range(0, 600))  # Random position

# Lobby functions
func _client_connected(peer_id : int) -> void:
	print("CLIENT ID:", peer_id, "Connected")
	if multiplayer.is_server():
		spawn_player()

func _client_disconnected(peer_id : int) -> void:
	print("CLIENT ID:", peer_id, "Disconnected")

func _connected_to_server() -> void:
	print("Connected to server!!")
	spawn_player()

func _connected_to_server_failed() -> void:
	print("Connected to server failed")

func _server_disconnected() -> void:
	print("Server disconnected")
