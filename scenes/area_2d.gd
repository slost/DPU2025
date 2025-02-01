extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the area_entered signal to detect when a bullet enters the area
	area_entered.connect(_on_area_entered)

# Called when another Area2D enters this area
func _on_area_entered(area: Area2D) -> void:
	# Check if the entering area is a bullet
	if area.is_in_group("bullets"):
		if area.has_method("_on_bullet_hit_b_soap"):
			print("Bullet entered b_soap area!")
			# Notify the server to update the shooter's score
			area._on_bullet_hit_b_soap(area.shooter_id)

# RPC to notify the server about the bullet hitting b_soap
