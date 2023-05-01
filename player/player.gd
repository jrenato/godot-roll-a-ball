extends RigidBody3D

@export var speed: float = 10.0

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	var input := Vector3.ZERO 
	input.x = Input.get_axis("move_left", "move_right") 
	input.z = Input.get_axis("move_forward", "move_back") 

	apply_central_force(input * speed)
