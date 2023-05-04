extends CharacterBody3D

var rotation_vector : Vector3 = Vector3(1, 1, 0)
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	pass
#	tween_rotate_loop()


func _process(delta: float) -> void:
	mesh_instance_3d.rotation += rotation_vector * delta


#func tween_rotate_loop():
#	var tween := create_tween()
#	tween.tween_property(self, "rotation", rotation_vector, 10.0)
#	tween.tween_callback(tween_rotate_loop)
