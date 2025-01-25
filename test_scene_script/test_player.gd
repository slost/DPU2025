extends Sprite2D


@export var face_sprite :Sprite2D
@export var head_sprite :Sprite2D
@export var area_player :Area2D


func _ready() -> void:
	area_player.area_entered.connect(_on_area)


func _cosmetic(head :int, face :int ,color :Color) -> void:
	face_sprite.frame = face
	head_sprite.frame = head
	$".".self_modulate = color


func _on_area(area :Area2D) -> void:
	if multiplayer.is_server():
		NetworkManager.players[multiplayer.get_unique_id()]["Hitting"] = true
		NetworkManager._sync_player_info.rpc(NetworkManager.players)
		get_parent().get_parent()._look_()
	else:
		_request_hitting.rpc_id(1)


@rpc("any_peer", "reliable")
func _request_hitting() -> void:
	if !multiplayer.is_server(): return
	NetworkManager.players[multiplayer.get_remote_sender_id()]["Hitting"] = true
	NetworkManager._sync_player_info.rpc(NetworkManager.players)
