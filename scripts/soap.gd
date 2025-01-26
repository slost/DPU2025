extends Area2D

var score :int = 1
var name_ :String = "soap"


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("_take_score"):
		area._take_score(score, name_)
