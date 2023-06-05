extends RigidBody3D

@export var speed: float = 10.0

@onready var count_label: Label = %CountLabel
@onready var message_label: Label = %MessageLabel
@onready var menu_container: VBoxContainer = %MenuVBoxContainer
@onready var restart_button: Button = %RestartButton
@onready var continue_button: Button = %ContinueButton
@onready var next_level_button: Button = %NextLevelButton
@onready var quit_button: Button = %QuitButton

@onready var mesh_instance: MeshInstance3D = %MeshInstance3D
@onready var death_particles: GPUParticles3D = %DeathParticles3D
@onready var pickup_area: Area3D = %PickupArea3D

var game_camera : Node3D
var spawn_position : Vector3

var count : int
var total_pickups : int


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	restart_button.pressed.connect(_on_restart_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

	spawn_position = position
	game_camera = get_parent().get_node("GameCamera")

	pickup_area.area_entered.connect(_on_area_entered)
	count = 0
	total_pickups = get_tree().get_nodes_in_group("pickups").size()

	set_count_text()

	message_label.visible = false
	menu_container.visible = false
	next_level_button.visible = false


func _process(delta: float) -> void:
	var input := Vector3.ZERO 
	input.x = Input.get_axis("move_left", "move_right") 
	input.z = Input.get_axis("move_forward", "move_back") 

	apply_central_force(game_camera.twist_pivot.basis * input * speed)


func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func set_count_text() -> void:
	if not count_label:
		return
	count_label.text = "Remaining: %s" % (total_pickups - count)

	if count >= total_pickups:
		set_victory_screen()


func set_victory_screen() -> void:
	message_label.text = "You Win!"
	message_label.visible = true
	menu_container.visible = true
	next_level_button.visible = true
	continue_button.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	freeze = true
	quit_button.grab_focus()


func set_defeat_screen() -> void:
	rotation = Vector3.ZERO
	mesh_instance.visible = false
	death_particles.emitting = true
	message_label.text = "You Lose!"
	message_label.visible = true
	menu_container.visible = true
	next_level_button.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	freeze = true
	continue_button.grab_focus()


func tween_capture(body : Node) -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(body, "global_position", self.global_position, 0.2)#\
		#.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(body, "scale", Vector3.ONE * 0.01, 0.2)
	tween.set_parallel(false)
	tween.tween_callback(body.queue_free)


func _on_area_entered(body : Node) -> void:
	if body.is_in_group("pickups"):
		count += 1
		set_count_text()
		tween_capture(body)

	if body.is_in_group("death_areas"):
		set_defeat_screen()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_continue_button_pressed() -> void:
	mesh_instance.visible = true
	message_label.visible = false
	menu_container.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	freeze = false
	position = spawn_position


func _on_quit_button_pressed() -> void:
	get_tree().quit()
