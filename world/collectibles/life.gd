extends Area3D

@onready var animation_player = %AnimationPlayer


func _ready():
	Signals.game_paused.connect(_on_game_paused)


func _on_game_paused(paused : bool) -> void:
	if paused:
		animation_player.pause()
	else:
		animation_player.play()
