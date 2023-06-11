@tool
extends Path3D

@onready var animation_player = %AnimationPlayer

@export var speed : int = 50 : 
	set(value):
		speed = value
		if Engine.is_editor_hint():
			await ready
			animation_player.speed_scale = speed / curve.get_baked_length()
	get:
		return speed


func _ready():
	if not Engine.is_editor_hint():
		Signals.game_paused.connect(_on_game_paused)
		animation_player.speed_scale = speed / curve.get_baked_length()


func _on_game_paused(paused : bool) -> void:
	if paused:
		animation_player.pause()
	else:
		animation_player.play()
