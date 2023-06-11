extends RigidBody3D

@export var speed: float = 10.0

@onready var count_label: Label = %CountLabel
@onready var lives_label = %LivesLabel
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

var lives : int = 3
var player_dead : bool = false
var last_velocity : Vector3 = Vector3.ZERO


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	restart_button.pressed.connect(_on_restart_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

	spawn_position = position
	game_camera = get_parent().get_node("GameCamera")

	body_entered.connect(_on_body_entered)
	pickup_area.area_entered.connect(_on_area_entered)
	count = 0
	total_pickups = get_tree().get_nodes_in_group("pickups").size()

	set_count_text()
	set_lives_text()

	message_label.visible = false
	menu_container.visible = false


func _process(delta: float) -> void:
	var input := Vector3.ZERO 
	input.x = Input.get_axis("move_left", "move_right") 
	input.z = Input.get_axis("move_forward", "move_back") 

	apply_central_force(game_camera.twist_pivot.basis * input * speed)


func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# get_tree().quit()
		last_velocity = linear_velocity
		set_pause_screen()


func set_count_text() -> void:
	if not count_label:
		return
	count_label.text = "Remaining: %s" % (total_pickups - count)

	if count >= total_pickups:
		set_victory_screen()


func set_lives_text() -> void:
	if not lives_label:
		return
	lives_label.text = "Lives: %s" % (lives)


func set_victory_screen() -> void:
	Signals.game_paused.emit(true)

	message_label.text = "You Win!"
	message_label.visible = true
	menu_container.visible = true

	restart_button.visible = true
	next_level_button.visible = true
	continue_button.visible = false
	quit_button.visible = true

	# next_level_button.grab_focus()
	quit_button.grab_focus()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	freeze = true


func set_defeat_screen() -> void:
	Signals.game_paused.emit(true)

	# Death Animation
	rotation = Vector3.ZERO
	mesh_instance.visible = false
	death_particles.emitting = true

	message_label.text = "You Lose!"
	message_label.visible = true
	menu_container.visible = true

	restart_button.visible = true
	next_level_button.visible = false

	if lives > 0:
		continue_button.visible = true
	else:
		continue_button.visible = false
		continue_button.disabled = true

	quit_button.visible = true

	continue_button.grab_focus()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	freeze = true


func set_pause_screen() -> void:
	Signals.game_paused.emit(true)

	message_label.text = "Paused"
	message_label.visible = true
	menu_container.visible = true

	restart_button.visible = true
	next_level_button.visible = false
	continue_button.visible = true
	quit_button.visible = true

	continue_button.grab_focus()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	freeze = true


func tween_capture(body : Node) -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(body, "global_position", self.global_position + (Vector3.UP * 2), 0.2)#\
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
		player_dead = true
		set_defeat_screen()


func _on_body_entered(body):
	if body.is_in_group("damage"):
		player_dead = true
		set_defeat_screen()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_continue_button_pressed() -> void:
	Signals.game_paused.emit(false)

	mesh_instance.visible = true
	message_label.visible = false
	menu_container.visible = false

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	freeze = false

	if player_dead:
		if lives <= 0:
			return

		lives -= 1
		set_lives_text()

		position = spawn_position
		linear_velocity = Vector3.ZERO
		player_dead = false
	else:
		linear_velocity = last_velocity
		last_velocity = Vector3.ZERO


func _on_quit_button_pressed() -> void:
	get_tree().quit()
