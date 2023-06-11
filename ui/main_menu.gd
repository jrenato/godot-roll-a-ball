extends CanvasLayer

@onready var start_button = %StartButton
@onready var options_button = %OptionsButton
@onready var credits_button = %CreditsButton
@onready var quit_button = %QuitButton


func _ready():
	start_button.grab_focus()

	start_button.button_up.connect(_on_start_button_button_up)
	options_button.button_up.connect(_on_options_button_button_up)
	credits_button.button_up.connect(_on_credits_button_button_up)
	quit_button.button_up.connect(_on_quit_button_button_up)


func _on_start_button_button_up():
	get_tree().change_scene_to_file("res://world/levels/level_01.tscn")


func _on_options_button_button_up():
	pass


func _on_credits_button_button_up():
	pass


func _on_quit_button_button_up():
	get_tree().quit()
