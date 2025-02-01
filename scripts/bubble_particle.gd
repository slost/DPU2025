extends Sprite2D

var speed: int = 5
var decay_time: float = 3.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
    speed = speed * scale.x
    rotation = rng.randf_range(0, 360)
    $AnimationPlayer.speed_scale = decay_time / 4

func _process(delta):
    
    $AnimationPlayer.play("animation")
    position.y -= speed * delta
    modulate.a -= delta / decay_time
    if modulate.a <= 0:
        queue_free()

