extends RigidBody3D

@export var speed: float = 10.0
@export var count_label: Label
@export var win_label: Label

var count : int

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	count = 0
	set_count_text()
	if win_label:
		win_label.visible = false


func _process(delta: float) -> void:
	var input := Vector3.ZERO 
	input.x = Input.get_axis("move_left", "move_right") 
	input.z = Input.get_axis("move_forward", "move_back") 

	apply_central_force(input * speed)


func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func set_count_text() -> void:
	if not count_label:
		return
	count_label.text = "Count: %s" % count

	if not win_label:
		return

	if count >= 12:
		win_label.visible = true


func _on_body_entered(body : Node) -> void:
	if body.is_in_group("pickups"):
		count += 1
		set_count_text()
		body.queue_free()


#func _physics_process(delta: float) -> void:
#	var bodies : Array[Node3D] = get_colliding_bodies()
#	for body in bodies:
#		if body.is_in_group("collectibles"):
#			body.queue_free()
