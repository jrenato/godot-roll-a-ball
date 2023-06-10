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
		animation_player.speed_scale = speed / curve.get_baked_length()
