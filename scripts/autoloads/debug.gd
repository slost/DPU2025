extends Node

func _input(event):
    
    if event is InputEventKey:
        if event.pressed:
            match event.keycode:
                KEY_F5:
                    # F5 to restart the game
                    get_tree().reload_current_scene()