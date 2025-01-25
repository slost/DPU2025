extends Area2D

@export var damage: int = 10

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("players"):
		var target_player = area.get_parent()
		if target_player.has_method("take_damage"):
			target_player.take_damage(damage)
