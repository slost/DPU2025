extends Node

func _ready() -> void:
    sfx_click()
    await get_tree().create_timer(0.2).timeout
    sfx_gameover()

func sfx_click() -> void:
    $Click.play()

func sfx_gameover() -> void:
    $GameOver.play()