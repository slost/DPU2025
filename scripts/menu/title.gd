class_name MainMenu
extends Control


@onready var margin_container = $MarginContainer as MarginContainer
@onready var options_menu = $Options as OptionsMenu
@onready var tutorial_page = $Tutorial_Page as TutorialPage
@onready var game_logo = $Logo as Sprite2D
@export var vbox_online :VBoxContainer


func _ready() -> void:
	vbox_online.visible = false
	handle_connecting_signal()


func _on_tutorial_pressed() -> void:
	tutorial_page.set_process(true)
	margin_container.visible = false
	game_logo.visible = false
	tutorial_page.visible = true
	
func _on_exit_tutorial_page() -> void:
	margin_container.visible = true
	game_logo.visible = true
	tutorial_page.visible = false

func _on_options_pressed() -> void:
	options_menu.set_process(true)
	margin_container.visible = false
	game_logo.visible = false
	options_menu.visible = true

func _on_exit_options_menu() -> void:
	margin_container.visible = true
	game_logo.visible = true
	options_menu.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func handle_connecting_signal() -> void:
	if options_menu != null:
		options_menu.exit_options_menu.connect(_on_exit_options_menu)

	if tutorial_page != null:
		tutorial_page.exit_tutorial_page.connect(_on_exit_tutorial_page)


func _on_play_pressed() -> void:
	vbox_online.visible = !vbox_online.visible
