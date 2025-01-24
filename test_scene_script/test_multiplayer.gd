extends Node2D

@export var ip_adress :TextEdit
@export var b_host :Button
@export var b_join :Button
@export var b_play :Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Title
	if multiplayer.is_server():
		b_join.hide()
		b_host.show()
	else:
		b_host.hide()
		b_join.show()
	
	#Lobby
	NetworkManager.client_connected
	NetworkManager.client_disconnected
	NetworkManager.connected_to_server
	NetworkManager.connected_to_server_failed
	NetworkManager.server_disconnected
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_b_host_pressed() -> void:
	if !multiplayer.is_server(): return
	NetworkManager._create_server()


func _on_b_join_pressed() -> void:
	if multiplayer.is_server(): return
	NetworkManager._create_client(ip_adress.text)
