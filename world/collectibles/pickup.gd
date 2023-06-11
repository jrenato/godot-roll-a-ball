extends Area3D

@onready var mesh_instance_3d : MeshInstance3D = $MeshInstance3D

var rotation_speed : float = 0.8

var paused_animation : bool = false


func _ready():
	Signals.game_paused.connect(_on_game_paused)


func _process(delta: float) -> void:
	if not paused_animation:
		mesh_instance_3d.rotate_object_local(Vector3(1, 0, 0), 1 * delta * rotation_speed)
		mesh_instance_3d.rotate_object_local(Vector3(0, 1, 0), 2 * delta * rotation_speed)
		mesh_instance_3d.rotate_object_local(Vector3(0, 0, 1), 3 * delta * rotation_speed)


func _on_game_paused(paused : bool) -> void:
	paused_animation = paused
