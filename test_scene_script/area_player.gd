extends Area2D



func _ready() -> void:
	name = str($"..") + "_area"


func _check_area(peer_id :int) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if multiplayer.is_server():
		if area.has_method("_check_area"):
			area._check_area(multiplayer.get_unique_id())


func _take_score(score :int, item :String) -> void:
	if !multiplayer.is_server(): return
	$"../../..".
