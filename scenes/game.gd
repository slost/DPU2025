extends Node2D

@export var speed_multiplier: float = 0.5

#multiplayer //////////////////
@export var player_instance :PackedScene
@export var anim_game_original :AnimatedSprite2D

@export var time_text :Label

@export var player_container :Node2D
@export var _time :Timer
@export var player_list_score :RichTextLabel
@export var player_info_text :RichTextLabel
@export var end_game_node :Control
@export var player_list_end_game :RichTextLabel


var start_game :bool
var end_game :bool
#//////////////////////////////




var is_pause: bool = false

#players info
var players_info :Dictionary


var slip_point :float = 0.3

#time
var time_level :int

#input
var can_input :bool

func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().create_timer(0.2).timeout
	
	NetworkManager.client_connected.connect(_client_connected)
	NetworkManager.client_disconnected.connect(_client_disconnected)
	NetworkManager.server_disconnected.connect(_server_disconnected)
	
	end_game_node.visible = false
	
	if multiplayer.is_server():
		for player_id :int in NetworkManager.players.keys():
			players_info[player_id] = {
				"Name" : NetworkManager.players[player_id]["Name"], 
				"Direction" : "", "Position" : Vector2(), 
				"Score" : 0, "Hitting" : false, "Limit" : 0.0, 
			}
			
			#sync plaeyr info
			if player_id != 1:
				_sync_player_info.rpc_id(player_id, players_info)
			await get_tree().create_timer(0.1).timeout
			_spawn_player.rpc(player_id)
			_duplicate_anim.rpc(player_id)
			_update_player_list_score.rpc()

		
		can_input = true
		_sync_can_input.rpc(can_input)
		#start time
		_time.start()
		$Limit_slppery.start()


#Input
func _input(event: InputEvent) -> void:
	if !can_input: return
	#Debuging
	if event.is_action_pressed("ui_cancel"):
		print(players_info)
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
	_update_own_info()

#Player inputing
func _on_player_input_left(peer_id :int, direction :String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)
	_update_player_list_score.rpc()


func _on_player_input_right(peer_id :int, direction :String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)
	_update_player_list_score.rpc()


func _on_player_input_up(peer_id :int, direction :String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)
	_update_player_list_score.rpc()


func _on_player_input_down(peer_id :int, direction :String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)
	_update_player_list_score.rpc()


func _on_player_input_stop(peer_id :int, direction :String) -> void:
	print(peer_id, direction)
	_player_movement(peer_id, direction)
	_update_player_list_score.rpc()


#player movement
func _player_movement(peer_id :int, direction :String) -> void:
	if multiplayer.is_server():
		if player_container.get_node_or_null(str(peer_id)):
			players_info[peer_id]["Direction"] = direction
			_anim_direction.rpc(peer_id, direction)
			_sync_player_info.rpc(players_info)
	else:
		_request_player_movement.rpc_id(1, peer_id, direction)


@rpc("any_peer", "reliable")
func _request_player_movement(peer_id :int, direction :String) -> void:
	if player_container.get_node_or_null(str(peer_id)):
		players_info[peer_id]["Direction"] = direction
		_anim_direction.rpc(peer_id, direction)
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


@rpc("authority", "reliable", "call_local")
func _update_player_list_score() -> void:
	player_list_score.text = ""
	for player_name :int in players_info.keys():
		player_list_score.text += "%s : score :%d |Slippery :%.3f\n" % [players_info[player_name]["Name"], players_info[player_name]["Score"], players_info[player_name]["Limit"]]

func _update_own_info() -> void:
	player_info_text.text = ""
	if !players_info.is_empty() :player_info_text.text = "Name :%s | Score :%d" % [players_info[multiplayer.get_unique_id()]["Name"], players_info[multiplayer.get_unique_id()]["Score"]]

@rpc("authority", "reliable", "call_local")
func _check_limit_soap() -> void:
	for player_id :int in players_info.keys():
		if players_info[player_id]["Limit"] >= 5:
			print(player_id, "END GAME")
			end_game = true
			_sync_end_game.rpc(end_game)
			_end_game.rpc()

#Animation direction
@rpc("authority", "reliable", "call_local")
func _anim_direction(peer_id :int, direction :String) -> void:
	player_container.get_node_or_null(str(peer_id)).get_node_or_null(str(peer_id) + "_anim").play(str(direction))


#Spawn player
@rpc("authority", "reliable", "call_local")
func _spawn_player(peer_id :int) -> void:
	var player :Sprite2D = player_instance.instantiate() as Sprite2D
	var plaeyr_face :int = NetworkManager.players[peer_id]["Face"]
	player.name = str(peer_id)
	player.position = Vector2(80, 584-140)
	player.scale = Vector2(5, 5)
	player._cosmetic(NetworkManager.players[peer_id]["Head"], NetworkManager.players[peer_id]["Face"], NetworkManager.players[peer_id]["Color"])
	player_container.add_child(player, true)

#Duplicate anim
@rpc("authority", "reliable", "call_local")
func _duplicate_anim(peer_id :int) -> void:
	var anim_dup :AnimatedSprite2D = anim_game_original.duplicate()
	anim_dup.visible = true
	anim_dup.name = str(peer_id) + "_anim"
	anim_dup.position.x += 0.0
	anim_dup.position.y += 10.0
	if player_container.get_node_or_null(str(peer_id)):
		player_container.get_node_or_null(str(peer_id)).add_child(anim_dup, true)


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

#sync_tiem_level
@rpc("authority", "reliable")
func _sync_time_level(new_time :int) -> void:
	time_level = new_time

#sync_input
@rpc("authority", "reliable")
func _sync_can_input(can :bool) -> void:
	can_input = can

#sync_end_game
@rpc("authority", "reliable")
func _sync_end_game(new_end_game :bool) -> void:
	end_game = new_end_game



func _on_timer_timeout() -> void:
	if !multiplayer.is_server(): return
	time_level += 1
	
	if time_level >= 2:
		for player_id :int in players_info.keys():
			_move_player.rpc(player_id, players_info[player_id]["Direction"], 64)
		for player_id :int in players_info.keys():
			players_info[player_id]["Direction"] = "stop"
			_anim_direction.rpc(player_id, "stop")
			_sync_player_info.rpc(players_info)
		time_level = 0
	_sync_time_level.rpc(time_level)

@rpc("authority", "reliable", "call_local")
func _kill_player(peer_id :int) -> void:
	_clean_node.rpc(peer_id)
	_sync_can_input.rpc_id(peer_id, false)
	


func _on_b_soap_pressed() -> void:
	if multiplayer.is_server():
		players_info[multiplayer.get_unique_id()]["Score"] += 1
		players_info[multiplayer.get_unique_id()]["Limit"] += slip_point
		_sync_player_info.rpc(players_info)
		_update_player_list_score.rpc()
		_check_limit_soap.rpc()
	else:
		_request_add_score.rpc_id(1)


@rpc("any_peer", "reliable")
func _request_add_score() -> void:
	if !multiplayer.is_server(): return
	players_info[multiplayer.get_remote_sender_id()]["Score"] += 1
	players_info[multiplayer.get_remote_sender_id()]["Limit"] += slip_point
	_sync_player_info.rpc(players_info)
	_update_player_list_score.rpc()
	_check_limit_soap.rpc()
	


@rpc("authority", "reliable", "call_local")
func _end_game() -> void:
	if end_game:
		can_input = false
		_sync_can_input.rpc(can_input)
		end_game_node.visible = true
		var max_score :int = 0
		var winner :String
		for player_id :int in players_info.keys():
			if players_info[player_id]["Score"] > max_score:
				max_score = players_info[player_id]["Score"]
				winner = players_info[player_id]["Name"]
			
		player_list_end_game.text = ""
		player_list_end_game.text = "WINNER IS %s!! SCORE :%d" % [winner, max_score]


func _on_limit_slppery_timeout() -> void:
	if !multiplayer.is_server(): return
	for player_id :int in players_info.keys():
		players_info[player_id]["Limit"] -= 0.1
		if players_info[player_id]["Limit"] < 0.0:
			players_info[player_id]["Limit"] == 0.0
		_sync_player_info.rpc(players_info)
	_update_player_list_score.rpc()
