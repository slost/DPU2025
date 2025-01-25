extends Sprite2D


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		position += Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 5
	
