extends Node3D

@export var next_level : PackedScene


func _ready() -> void:
	Signals.next_level.connect(load_next_level)


func load_next_level() -> void:
	if next_level:
		get_tree().change_scene_to_packed(next_level)
