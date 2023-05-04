extends CharacterBody3D

@onready var mesh_instance_3d : MeshInstance3D = $MeshInstance3D

var rotation_speed : float = 0.8


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	mesh_instance_3d.rotate_object_local(Vector3(1, 0, 0), 1 * delta * rotation_speed)
	mesh_instance_3d.rotate_object_local(Vector3(0, 1, 0), 2 * delta * rotation_speed)
	mesh_instance_3d.rotate_object_local(Vector3(0, 0, 1), 3 * delta * rotation_speed)
