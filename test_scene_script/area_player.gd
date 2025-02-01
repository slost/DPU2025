extends Area2D



func _ready() -> void:
	name = str($"..") + "_area"


func _take_score(score :int, item :String) -> void:
	print(get_parent()._my_peer_id())
	#print(score, item, peer_id)
