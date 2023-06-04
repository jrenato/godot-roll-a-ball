extends Node3D

@export var player: RigidBody3D

@onready var twist_pivot: Node3D = %TwistPivot
@onready var pitch_pivot: Node3D = %PitchPivot

var mouse_sensitivity : float = 0.001
var camera_sensitivity : float = 0.02
var twist_input : float = 0.0
var pitch_input : float = 0.0

var offset : Vector3


func _ready() -> void:
	if player:
		offset = global_position - player.global_position


func _process(delta: float) -> void:
	# TODO: Reference for the future
#	if Input.is_action_just_pressed("ui_cancel"):
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if player:
		global_position = player.global_position + offset

	var camera_input := Vector3.ZERO 
	camera_input.x = Input.get_axis("move_camera_right", "move_camera_left")
	camera_input.z = Input.get_axis("move_camera_back", "move_camera_forward")

	print(camera_input)

	if twist_input == 0 and camera_input.x != 0:
		twist_input = camera_input.x * camera_sensitivity

	if pitch_input == 0 and camera_input.z != 0:
		pitch_input = camera_input.z * camera_sensitivity

	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, 
		deg_to_rad(-10), 
		deg_to_rad(20) 
	) 

	twist_input = 0 
	pitch_input = 0 


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity
