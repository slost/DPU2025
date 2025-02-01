extends Node2D

@export var speed: float = 500.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 2.0

var shooter_id: int = -1  # Store the shooter's ID
var timer: float = 0.0

func _ready() -> void:
	# Set the bullet's rotation based on its direction
	rotation = direction.angle()
	# Add the bullet to the "bullets" group
	add_to_group("bullets")

func _physics_process(delta: float) -> void:
	# Move the bullet
	position += direction * speed * delta

	# Destroy the bullet after its lifetime expires
	timer += delta
	if timer >= lifetime:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Handle collision with other objects (e.g., players, walls, b_soap)
	if body.is_in_group("players"):
		# Damage the player or handle collision logic
		print("Bullet hit player:", body.name)
	elif body.name == "b_soap":  # Check if the bullet hits b_soap
		print("Bullet hit b_soap!")
		_on_bullet_hit_b_soap.rpc_id(1, shooter_id)  # Notify the server to update the score
	queue_free()  # Destroy the bullet on collision

@rpc("any_peer", "reliable")
func _on_bullet_hit_b_soap(shooter_id: int) -> void:
	if multiplayer.is_server():
		# Update the score of the player who shot the bullet
		var game_node = get_node("/root/Game")  # Access the game.gd script instance
		if game_node.players_info.has(shooter_id):
			game_node.players_info[shooter_id]["Score"] += 1
			game_node._sync_player_info.rpc(game_node.players_info)
			game_node._update_player_list_score.rpc()
