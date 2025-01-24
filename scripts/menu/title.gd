class_name MainMenu
extends Control


#Title
@onready var margin_container = $Title/MarginContainer as MarginContainer
@onready var options_menu = $Title/Options as OptionsMenu
@onready var tutorial_page = $Title/Tutorial_Page as TutorialPage
@onready var game_logo = $Title/Logo as Sprite2D
@export var title :Control
@export var lobby :Control
@export var vbox_online :VBoxContainer
@export var bg :TextureRect
@export var title_lobby_anim :AnimationPlayer
@export var get_ip_adress :LineEdit

#Lobby
@export var player_name :Label
@export var change_name :LineEdit
@export var players_list :RichTextLabel


func _ready() -> void:
	#Title
	vbox_online.visible = false
	handle_connecting_signal()
	title.visible = true
	lobby.visible = false
	#Lobby
	NetworkManager.client_connected.connect(_client_connected)
	NetworkManager.client_disconnected.connect(_client_disconnected)
	NetworkManager.connected_to_server.connect(_connected_to_server)
	NetworkManager.connected_to_server_failed.connect(_connected_to_server_failed)
	NetworkManager.server_disconnected.connect(_server_disconnected)


#//////////////////////////
#Title
func _on_tutorial_pressed() -> void:
	tutorial_page.set_process(true)
	margin_container.visible = false
	game_logo.visible = false
	tutorial_page.visible = true
	
func _on_exit_tutorial_page() -> void:
	margin_container.visible = true
	game_logo.visible = true
	tutorial_page.visible = false

func _on_options_pressed() -> void:
	options_menu.set_process(true)
	margin_container.visible = false
	game_logo.visible = false
	options_menu.visible = true

func _on_exit_options_menu() -> void:
	margin_container.visible = true
	game_logo.visible = true
	options_menu.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func handle_connecting_signal() -> void:
	if options_menu != null:
		options_menu.exit_options_menu.connect(_on_exit_options_menu)

	if tutorial_page != null:
		tutorial_page.exit_tutorial_page.connect(_on_exit_tutorial_page)


func _on_play_pressed() -> void:
	vbox_online.visible = !vbox_online.visible


#///////////////////////////
#Lobby

func _input(event: InputEvent) -> void:
	if multiplayer.multiplayer_peer == null: return
	if multiplayer.is_server():
		if event.is_action_pressed("ui_accept"):
			_show_player_list()
			_show_player_name.rpc()
			print(NetworkManager.players)
	else:
		if event.is_action_pressed("ui_down"):
			print(NetworkManager.players)

#/////////////
#NAME

#chane player name
func _change_player_name(new_name :String) -> void:
	if multiplayer.is_server():
		NetworkManager.players[1]["Name"] = new_name
		_show_player_name()
		_show_player_list.rpc()
		NetworkManager._sync_player_info.rpc(NetworkManager.players)
	else:
		_request_change_player_name.rpc_id(1, new_name)
	

@rpc("any_peer", "reliable", "call_local")
func _request_change_player_name(new_name :String) -> void:
	if !multiplayer.is_server(): return
	var sender_peer :int = multiplayer.get_remote_sender_id()
	NetworkManager.players[sender_peer]["Name"] = new_name
	_show_player_name.rpc()
	_show_player_list.rpc()
	NetworkManager._sync_player_info.rpc(NetworkManager.players)

#show player name
@rpc("authority", "reliable")
func _show_player_name() -> void:
	var my_peer :int = multiplayer.get_unique_id()
	player_name.text = str(NetworkManager.players[my_peer]["Name"])

#show player list
@rpc("authority", "reliable", "call_local")
func _show_player_list() -> void:
	players_list.text = ""
	for player_id :int in NetworkManager.players.keys():
		players_list.text += NetworkManager.players[player_id].Name + "\n"


func _on_host_pressed() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
		#await get_tree().create_timer(0.5).timeout
	title_lobby_anim.play("change_color_to_lobby")
	title.visible = false
	lobby.visible = true
	NetworkManager._create_server()
	_show_player_name()
	_show_player_list.rpc()


func _on_join_pressed() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
		print("Connecting...")
		await get_tree().create_timer(0.5).timeout
		title_lobby_anim.play("change_color_to_lobby")
		title.visible = false
		lobby.visible = true
	NetworkManager._create_client(get_ip_adress.text)
	


func _client_connected(peer_id :int) -> void:
	print("CLIENT ID:",peer_id, "Connected")
	_show_player_name.rpc()
	_show_player_list.rpc()

func _client_disconnected(peer_id :int) -> void:
	print("CLIENT ID:", peer_id, "Disconnected")

func _connected_to_server() -> void:
	print("connected to server!!")
	#_show_player_name()

func _connected_to_server_failed() -> void:
	print("Connected tp server failed")

func _server_disconnected() -> void:
	print("server disconnected")


func _on_change_name_text_changed(new_text: String) -> void:
	_change_player_name(new_text)
