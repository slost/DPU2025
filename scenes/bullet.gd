extends Node2D

@export var speed: float = 500.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 2.0

var timer: float = 0.0

func _ready() -> void:
	# Set the bullet's rotation based on its direction
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Move the bullet
	position += direction * speed * delta

	# Destroy the bullet after its lifetime expires
	timer += delta
	if timer >= lifetime:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Handle collision with other objects (e.g., players, walls)
	if body.is_in_group("players"):
		# Damage the player or handle collision logic
		print("Bullet hit player:", body.name)
	queue_free()  # Destroy the bullet on collision
