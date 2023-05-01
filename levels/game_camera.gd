extends Camera3D

@export var player: RigidBody3D

var offset : Vector3


func _ready() -> void:
	if player:
		offset = global_position - player.global_position


func _process(delta: float) -> void:
	if player:
		global_position = player.global_position + offset
