class_name MainMenu
extends Control


#Title
@onready var margin_container :MarginContainer = $Title/MarginContainer
@onready var options_menu :OptionsMenu = $Title/Options
@onready var tutorial_page :TutorialPage = $Title/Tutorial_Page
@onready var game_logo :Sprite2D = $Title/Logo
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
@export var b_play :Button
@export var b_ready :Button
@export var head_sprite :Sprite2D
@export var face_sprite :Sprite2D
@export var base_overview :Sprite2D
@export var face_overview :Sprite2D
@export var head_overview :Sprite2D
@export var color_picker : ColorPicker


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
#Debuging
func _input(event: InputEvent) -> void:
	if multiplayer.multiplayer_peer == null: return
	if multiplayer.is_server():
		if event.is_action_pressed("ui_cancel"):
			print(NetworkManager.players)
	else:
		if event.is_action_pressed("ui_down"):
			print(NetworkManager.players)


#//////////////////////////////////
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
	

#request change name
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

func _is_ready_player(p:bool) -> String:
	if p :
		return "Ready : YES"
	else:
		return "Ready : NO"

@rpc("authority", "reliable", "call_local")
func _show_player_list() -> void:
	players_list.text = ""
	for player_id :int in NetworkManager.players.keys():
		#var ready_player :bool = NetworkManager.players[player_id].Ready
		players_list.text += "%s Ready :%s\n" % [NetworkManager.players[player_id].Name, "YES" if NetworkManager.players[player_id].Ready else "No"]
		#players_list.text += NetworkManager.players[player_id].Name + _is_ready_player(ready_player) + "\n"

#//////////////////////////////////



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
	b_play.visible = true
	b_ready.visible = false
	#set_frame
	


func _on_join_pressed() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
		print("Connecting...")
		await get_tree().create_timer(0.5).timeout
		title_lobby_anim.play("change_color_to_lobby")
		title.visible = false
		lobby.visible = true
	NetworkManager._create_client(get_ip_adress.text)
	b_play.visible = false
	b_ready.visible = true
	


func _client_connected(peer_id :int) -> void:
	print("CLIENT ID:",peer_id, "Connected")
	_show_player_name.rpc()
	_show_player_list.rpc()


func _client_disconnected(peer_id :int) -> void:
	print("CLIENT ID:", peer_id, "Disconnected")


func _connected_to_server() -> void:
	print("connected to server!!")
	#_show_player_name()
	b_play.visible = false
	b_ready.visible = true

func _connected_to_server_failed() -> void:
	print("Connected tp server failed")


func _server_disconnected() -> void:
	print("server disconnected")


func _on_change_name_text_changed(new_text: String) -> void:
	_change_player_name(new_text)


#Play 
func _on_b_play_pressed() -> void:
	if !multiplayer.is_server(): return
	await get_tree().physics_frame
	
	var found_ready :Array
	for player_id :int in NetworkManager.players.keys():
		found_ready.append(NetworkManager.players[player_id]["Ready"])
	
	if !found_ready.has(false):
		await get_tree().create_timer(0.1).timeout
		NetworkManager._load_game.rpc("res://scenes/game.tscn")
		print("CHANGE SCENE")
	else: return


#Ready
func _on_b_ready_pressed() -> void:
	if !multiplayer.is_server(): _request_client_ready.rpc_id(1)


#Ready change ready from client
@rpc("any_peer", "reliable")
func _request_client_ready() -> void:
	if !multiplayer.is_server(): return
	var sender_id :int = multiplayer.get_remote_sender_id()
	NetworkManager.players[sender_id]["Ready"] = !NetworkManager.players[sender_id]["Ready"]
	NetworkManager._sync_player_info.rpc(NetworkManager.players)
	_show_player_list.rpc()


#Character
func _change_chracter(peer_id :int, part :String, frame :int) -> void:
	if multiplayer.is_server():
		NetworkManager.players[peer_id][part] = frame
		NetworkManager._sync_player_info.rpc(NetworkManager.players)

	else:
		_request_change_character.rpc_id(1, peer_id , part, frame)

@rpc("any_peer", "reliable")
func _request_change_character(peer_id :int, part :String, frame :int) -> void:
	if !multiplayer.is_server(): return
	NetworkManager.players[peer_id][part] = frame
	NetworkManager._sync_player_info.rpc(NetworkManager.players)


#///////////////////////////////////////
#Button change character frame
func _on_b_left_head_pressed() -> void:
	if head_sprite.frame == 0 :
		head_sprite.frame = 2 
	else:
		head_sprite.frame -= 1 
	head_overview.frame = head_sprite.frame
	_change_chracter(multiplayer.get_unique_id(), "Head", head_sprite.frame)

func _on_b_left_face_pressed() -> void:
	if face_sprite.frame == 0 :
		face_sprite.frame = 2 
	else:
		face_sprite.frame -= 1 
	face_overview.frame = face_sprite.frame
	_change_chracter(multiplayer.get_unique_id(), "Face", face_sprite.frame)

func _on_b_right_head_pressed() -> void:
	if head_sprite.frame == 2 :
		head_sprite.frame = 0 
	else:
		head_sprite.frame += 1 
	head_overview.frame = head_sprite.frame
	_change_chracter(multiplayer.get_unique_id(), "Head", head_sprite.frame)

func _on_b_right_face_pressed() -> void:
	if face_sprite.frame == 2 :
		face_sprite.frame = 0
	else:
		face_sprite.frame += 1 
	face_overview.frame = face_sprite.frame
	_change_chracter(multiplayer.get_unique_id(), "Face", face_sprite.frame)


func _on_color_picker_color_changed(color: Color) -> void:
	$Lobby/Create_character/HBoxContainer/VBoxContainer2/overview/base_overview.modulate = color
	_change_color_modulate(multiplayer.get_unique_id(), color)

#Change color
func _change_color_modulate(peer_id :int, color :Color) -> void:
	if multiplayer.is_server():
		NetworkManager.players[peer_id]["Color"] = color
		NetworkManager._sync_player_info.rpc(NetworkManager.players)
	else:
		_request_change_color_modulate.rpc_id(1, peer_id, color)

@rpc("any_peer", "reliable")
func _request_change_color_modulate(peer_id :int, color :Color) -> void:
	if !multiplayer.is_server(): return
	NetworkManager.players[peer_id]["Color"] = color
	NetworkManager._sync_player_info.rpc(NetworkManager.players)
