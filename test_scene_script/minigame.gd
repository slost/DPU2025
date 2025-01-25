extends Control

var turn :bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i :int in $GridContainer.get_child_count():
		$GridContainer.get_child(i).pressed.connect(_on_b_node_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_b_node_pressed() -> void:
	pass
