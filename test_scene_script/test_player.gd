extends Sprite2D


@export var face_sprite :Sprite2D
@export var head_sprite :Sprite2D
@export var area_player :Area2D


func _ready() -> void:
	area_player.area_entered.connect(_on_area)
	area_player.area_exited.connect(_exit_area)


func _cosmetic(head :int, face :int ,color :Color) -> void:
	face_sprite.frame = face
	head_sprite.frame = head
	$".".self_modulate = color


func _on_area(area :Area2D) -> void:
	if multiplayer.is_server():
		get_parent().get_parent().players_info[multiplayer.get_unique_id()]["Hitting"] = true
		get_parent().get_parent()._sync_player_info.rpc(get_parent().get_parent().players_info)
		get_parent().get_parent()._take_damage.rpc(multiplayer.get_unique_id())
	else:
		_request_hitting.rpc_id(1)


@rpc("any_peer", "reliable")
func _request_hitting() -> void:
	if !multiplayer.is_server(): return
	get_parent().get_parent().players_info[multiplayer.get_remote_sender_id()]["Hitting"] = true
	get_parent().get_parent()._sync_player_info.rpc(get_parent().get_parent().players_info)
	get_parent().get_parent()._take_damage.rpc(multiplayer.get_remote_sender_id())


func _exit_area(area :Area2D) -> void:
	if multiplayer.is_server():
		get_parent().get_parent().players_info[multiplayer.get_unique_id()]["Hitting"] = false
		get_parent().get_parent()._sync_player_info.rpc(get_parent().get_parent().players_info)
	else:
		_request_exiting.rpc_id(1)


@rpc("any_peer", "reliable")
func _request_exiting() -> void:
	if !multiplayer.is_server(): return
	get_parent().get_parent().players_info[multiplayer.get_remote_sender_id()]["Hitting"] = false
	get_parent().get_parent()._sync_player_info.rpc(get_parent().get_parent().players_info)
