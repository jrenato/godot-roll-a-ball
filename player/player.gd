extends RigidBody3D

@export var speed: float = 10.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	var input := Vector3.ZERO 
	input.x = Input.get_axis("move_left", "move_right") 
	input.z = Input.get_axis("move_forward", "move_back") 

	apply_central_force(input * speed)


func _on_body_entered(body : Node) -> void:
	if body.is_in_group("collectibles"):
		body.queue_free()
	if body.is_in_group("test"):
		print(body)


#func _physics_process(delta: float) -> void:
#	var bodies : Array[Node3D] = get_colliding_bodies()
#	for body in bodies:
#		if body.is_in_group("collectibles"):
#			body.queue_free()
