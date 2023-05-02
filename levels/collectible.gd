extends MeshInstance3D

var rotation_vector : Vector3 = Vector3(15, 30, 45)

func _ready() -> void:
	pass
#	tween_rotate_loop()

func _process(delta: float) -> void:
	rotation += rotation_vector * delta * 0.1

#func tween_rotate_loop():
#	var tween := create_tween()
#	tween.tween_property(self, "rotation", rotation_vector, 10.0)
#	tween.tween_callback(tween_rotate_loop)
