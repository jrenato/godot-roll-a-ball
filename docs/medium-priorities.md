# Medium Priorities

## Camera controls

A static camera is not very good for a 3D game. It's boring. The player should be able to rotate the camera around the player, and look up and down a light bit at least.

Although it's a slightly more advanced topic, Bramwell's [Godot 4 Beginner's tutorial](https://bramwell.itch.io/godot-4-beginners) provided me with a good starting point.

His solution involves adding two nodes on the Player scene that act as pivots: TwistPivot and PitchPivot, then moving the Camera from the Level scene to the PitchPivot node. Finally, he adds a script to the Player that rotates the pivots based on the mouse movement.

That won't be so simple in this case, because the Player is a ball that rolls around, and the camera will follow it, rotating around it. So had to adapt the solution a bit.

The solution I came up with is to keep the camera as a separate scene as it is right now, `levels/game_camera.tscn`, and add the TwistPivot and PitchPivot nodes to it. It will bring only a tiny problem that I'll explain later.

The first step was, on the `Level` scene, to add the GameCamera as local node back to the level scene, right clicking on it and selecting "Make Local".

Next I:
* Renamed the `GameCamera` back to `Camera3D`
* Added a Node3D to the root of the level and renamed it `GameCamera`
* Added another Node3D - TwistPivot - as a child of the `GameCamera`
* Added another Node3d - PitchPivot - as a child of the TwistPivot
* Dettached the `game_camera.gd` script from the Camera3D and attached it to the new `GameCamera` node.
* Finally, I moved the Camera3D to the PitchPivot

Then I saved the new `GameCamera` as `levels/game_camera.tscn` (ovewriting the old one).

One simple change on `game_camera.gd` and I restored the original behaviour:

```gdscript
extends Node3D # <-- was Camera3D
```

Moving on, I started improving the `game_camera.gd` script.

First things first, I added the references and variables I'll need:

```gdscript
@onready var twist_pivot: Node3D = %TwistPivot
@onready var pitch_pivot: Node3D = %PitchPivot

var mouse_sensitivity : float = 0.001
var twist_input : float = 0.0
var pitch_input : float = 0.0
```

Next I changed the mouse mode to captured:

```gdscript
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    (...)
```

For future reference, I'll change the mnouse mode again when I implement the pause screen using _Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)_

Next, I have to store the mouse movement in the `twist_input` and `pitch_input` variables:

```gdscript
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity
```

Then, I have to rotate the pivots:

```gdscript
func _process(delta):
    (...)
    twist_pivot.rotate_y(twist_input)
    pitch_pivot.rotate_x(pitch_input)
```

It's important to clamp the pitch rotation to avoid the camera to rotate too much:

```gdscript
    (...)
    pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, 
		deg_to_rad(-10), 
		deg_to_rad(20) 
	)
```

After some experimentation, I found that the values -10 and 20 work well for the pitch rotation.

Finally, I have to reset the values of the `twist_input` and `pitch_input` variables:

```gdscript
func _process(delta):
    (...)

	twist_input = 0 
	pitch_input = 0 
```

It works! The camera rotates around the player, and the player can look up and down a bit.

But as I mentioned before, there's a problem. The camera rotates around the player, but the direction the player is moved is always the same. The problem is in this liune of code:

_player.gd_
```gdscript
func _process(delta: float) -> void:
    (...)
    apply_central_force(input * speed)
```

The apply_central_force() only takes into account the direction of the input, not the direction the player - or the camera - is facing.

Bramwell's provided a solution for it using the [twist_pivot.basis](https://docs.godotengine.org/en/latest/classes/class_node3d.html#class-node3d-property-basis):

```gdscript
# Bramwell's solution
apply_central_force(twist_pivot.basis * input * speed)
```

But in this project, the Player and the GameCamera are in different scenes, so I can't access the `twist_pivot` directly from the Player.

So I had to find a way to access the `twist_pivot` from the Player.

First I added a reference to the GameCamera in the Player:

```gdscript
var game_camera : Node3D
```

Then I set it in the `_ready()` function:

```gdscript
func _ready() -> void:
	game_camera = get_parent().get_node("GameCamera")
```

Since the Player and the GameCamera are siblings on the Level scene, first I get the parent of the Player, which is the Level, and then I get the GameCamera node from it.

Finally, I can use the `game_camera` reference to access the `twist_pivot`:

```gdscript
func _process(delta: float) -> void:
    (...)
    apply_central_force(game_camera.twist_pivot.basis * input * speed)
```

And that fixes the problem! It was a fun exercise.

One positive side effect of this solution is that, since the GameCamera is a separate scene, it won't be difficult to implement the Player's death and respawn. I'll just have to make the GameCamera stop following the Player when it dies, and then detect the new Player and lerp it back to the Player when it respawns.

## Modular Gridmap

The level is very small, and it's not very interesting. It would be nice to have a bigger level, with more pickups and obstacles.

According to the docs, [Gridmap](https://docs.godotengine.org/en/stable/tutorials/3d/using_gridmaps.html) is a tool for creating 3D game levels, similar to the way TileMap works in 2D.

It sounds like a good fit for this project, so I'll give it a try. Once more, Bramwell's course was very helpful to learn how to use it.

The first step is to create a [MeshLibrary](https://docs.godotengine.org/en/stable/classes/class_meshlibrary.html) to store the meshes I'll use to build the level.

I just created a new scene with a Node3D as root and saved it as `levels/tileset.tscn`.

Next I created a MeshInstance as a child of the root, named it `FloorMesh` and set it as a 2.0 x 0.1 x 2.0 BoxMesh. Then I added collision to it using the `Mesh > Create Trimesh Static Body` command.

I did the same with a second MeshInstance, named it `WallMesh` and set it as a 2.0 x 2.2 x 2.0 BoxMesh.

Then I set the same materials I was using for the `Ground` and `Walls` to the `FloorMesh` and `WallMesh` respectively.

To have a better visualisation of the meshes, I set the `WallMesh` transform to `-2.0 x 0.0 x 0.0`.

This was the result:
![Tileset](images/tileset.png)

_(I could have used a smaller, thinner mesh for the Wall and rotate it whenever I needed on the GridMap, but I decided to keep things simple for now and just use a bigger "fits-all" mesh.)_

Next, on the Level scene, I deleted the `Ground` and `Walls` nodes and added a GridMap node as a child of the Level root.

Then I added the `tileset.tscn` to the GridMap's `MeshLibrary` property, and draw the following map, duplicating some pikcups as well:

![GridMap](images/gridmap.png)

And voilà! The level is a little more interesting now.

![Expanded Level](images/expanded_level_01.png)
![Expanded Level](images/expanded_level_02.png)

And since I updated the way that the victory condition is checked, I didn't have to worry about those new pickups. It doen't matter how many pickups there are, the player just has to collect all of them to win.

![Expanded Level](images/expanded_level_03.png)

Also, the fact that the player can now rotate the camera around the player makes it easier to navigate the level.

But there are two immediate issues that are bothering me:

* That brownish color of the level's background is not very appealing. I'd like to change it too.
* If the player falls from the level, nothing happens. It would be nice to have a death check and respawn the player at the start of the level.

The first issue was easy to fix. I looked around the options for the `WorldEnvironment` node and found the `Environment > Sky > Sky Material > Ground > Bottom Color` property.

![Environment Ground Color](images/environment_ground_color.png)

I changed it to a darker blue, and in my opinion it looks better now.

![Expanded Level](images/expanded_level_04.png)

The second issue required some thought, so I decided to fix in the next section.

## Player Death and Respawn

Now that the Level is bigger, it's possible for the player to fall from it. And if that happens, nothing happens. The player just keeps falling forever.

I can think of two ways to fix this:

* Check the player's position and respawn it at the start of the level if it falls below a certain threshold.
* Add an `Area3D` node to the level, and check if the player enters it. If it does, respawn it at the start of the level.

I can think of pros and cons for both approaches.

The first approach is simpler, but I will always have to consider the hardcoded threshold when designing the level. If ever decide to expand the level to a lower level, I'll have to change the threshold as well.

The second approach makes more sense to me. I can add a very, very big `Area3D` node to the level, and if the player falls from the level, it will eventually enter the `Area3D` and trigger the death-respawn sequence. This approach is also flexible enough to allow me to add death traps to the level, like a pit of spikes or a lava pool, even if they're not at the bottom of the level.

I can also combine both approaches. Have the `Area3D` as the main death-respawn trigger, and use the threshold as a fallback in case I forget to add the `Area3D` to a new level or the player manages to find a way to fall from the level without entering the `Area3D`.

Since the level is very simple yet, I'll just go with the second approach for now.

To start, I added a new `Area3D` node to the Level scene and named it `DeathArea`.

Since I plan to make it flexible enough to work with any level, I won't have a default `CollisionShape` as a child of the `DeathArea`. Instead, I'll add for each individual instance of the `DeathArea` node. This way I can have different shapes for each level.

So I right-clicked on the `DeathArea` node and selected `Save Branch as Scene`. Then I saved it as `levels/death_area.tscn`.

I opened the `death_area.tscn` scene and attached a script to it, `death_area.gd`, and added the following code:

```gdscript
extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body : Node3D) -> void:
	if body.name == "Player":
		get_tree().reload_current_scene()
```

For now, I'll just reload the current scene when the player enters the `DeathArea`. I'll add the respawn logic later.

Then I went back to the Level scene and added a `CollisionShape` node as a child of the `DeathArea` node. I set it as a 200.0 x 1.0 x 200.0 BoxShape. Yes, it's a very big box, but it's just a placeholder for now. I can fine tune it later.

Finally, I moved the `DeathArea` node a little bit below the level, setting it's transform to `0.0 x -7.0 x 0.0`.

I tested it, and it worked as expected. If the player falls from the level, the whole scene is reloaded, looking like the player respawned at the start of the level and lost all the pickups it had collected.

## Losing and Restarting the Level

Reloading the whole scene when the player falls from the level is a very, very simple way to implement the death-respawn logic.

It works? Yes. Is it good enough? No. I don't like the fact that the whole scene is immediately reloaded. It's not a very good user experience. The camera just snaps back abruptly to the start of the level. It feels like a hack, not a feature.

It would be much better if the player just respawned at the start of the level, without the scene reloading. The camera could just move smoothly back to the start of the level and the player would keep the pickups it had collected.

Since it'll involve adding logic to the level itself, I'll implement this idea in the future. Perhaps adding `Player Lives` as well, so the player can have a few tries before having to restart the level entirely.

For now, there's an easier way to improve this situation: adding a "Game Over" message when the player falls from the level, with an option to restart the level or quit the game.

I already have a "You Win!" message, so I'll just add a "You Lose!" message as well, and include buttons to "Restart" and "Quit". I also remember that I'll have to deal with the mouse cursor again, since I always hide it when the game starts.

So, to start, I renamed "WinLabel" to "MessageLabel", since it'll be used for both "You Win!" and "You Lose!" messages.

Next I added another `MarginContainer` node as a child of the root node, a `VBoxContainer` node as a child of it, and two buttons to the `VBoxContainer` node, one for "Restart" and another for "Quit".

The Player scenetree now looks like this:

![Player SceneTree](images/player_restart_scenetree.png)

For this new `MarginContainer` node, I set the `Anchors Presets` to `Center Bottom` and `Margin Bottom` to `150`.

On the `VBoxContainer` I set the Custom Minimum Size to 150 x 0 and Separation to 10.

Then it's time to update the `player.gd` script.

First, I added the references to the new nodes that I'll need:

```gdscript
@onready var message_label: Label = %MessageLabel # Previously WinLabel
@onready var menu_container: VBoxContainer = %MenuVBoxContainer
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton
```

Next I have to hide the menu_container just like I hide the message_label when the game starts:

```gdscript
func _ready() -> void:
	(...)
	message_label.visible = false
	menu_container.visible = false
```

I had to update the set_count_text method as well:

```gdscript
func set_count_text() -> void:
	(...)
	if count >= total_pickups:
		message_label.text = "You Win!"
		message_label.visible = true
```

Now there's a new issue: I need to display the menu_container and lose message_label when the player falls from the level, but it's the DeathArea node that detects the collision, not the Player node.

So I obliterated the `DeathArea` script, included the DeathArea scene to the "death_areas" group, and added the following code to the `player.gd` script:

```gdscript
func _on_area_entered(body : Node) -> void:
	(...)
	if body.is_in_group("death_areas"):
		message_label.text = "You Lose!"
		message_label.visible = true
		menu_container.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		freeze = true
```

One moment to consider that last line, `freeze = true`.

First I tried to pause the entire game using `get_tree().paused = true`, but it paused everything. I mean `everything`: pressing "Esc" to quit the game didn't work anymore.

Reading the docs I found out that I could set the "Process Mode" of the Player node to "Always" to be able to click the buttons and exit, but then it would be pointless to pause the game at all, since the player would still endlessly fall from the level.

Then I read about [freeze](https://docs.godotengine.org/en/latest/classes/class_rigidbody3d.html#class-rigidbody3d-property-freeze): _If true, the body is frozen. Gravity and forces are not applied anymore_

That's exactly what I need. I just want to freeze the player in place, so it doesn't fall from the level anymore. I don't want to pause the game, just freeze the player.

Next, I added the `_on_restart_pressed` and `_on_quit_pressed` methods:

```gdscript
(...)
func _on_restart_button_pressed() -> void:
		message_label.visible = false
		menu_container.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		freeze = false


func _on_quit_button_pressed() -> void:
	get_tree().quit()
```

I also connected the `pressed` signal of the buttons to the methods on _ready():

```gdscript
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	restart_button.pressed.connect(_on_restart_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
(...)
```

Next I had to find a way to reposition the player at the start of the level.

It was actually very simple. First I needed to store the initial position of the player in a variable:

```gdscript
var spawn_position : Vector3
(...)

func _ready() -> void:
(...)
	spawn_position = position
```

Then I just had to set the position of the player to the spawn_position when the restart button is pressed:

```gdscript
func _on_restart_button_pressed() -> void:
	(...)
	position = spawn_position
```

And that's it. The player now respawns at the start of the level when the restart button is pressed. It's not as polished as I'd like, but it's good enough for now.

## Gamepad Support

First thing I did was to add new input actions for the gamepad:

![Input Actions](images/gamepad_input_actions_camera.png)

Next I updated the `game_camera.gd` script to use the gamepad:

```gdscript
func _process(delta: float) -> void:
	(...)
	var camera_input := Vector3.ZERO 
	camera_input.x = Input.get_axis("move_camera_right", "move_camera_left")
	camera_input.z = Input.get_axis("move_camera_back", "move_camera_forward")

	if twist_input == 0 and camera_input.x != 0:
		twist_input = camera_input.x * camera_sensitivity

	if pitch_input == 0 and camera_input.z != 0:
		pitch_input = camera_input.z * camera_sensitivity

	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	(...)
```

If twist_input and pitch_input are 0, then the gamepad is probably being used to rotate the camera. If they're not 0, then the mouse is being used to rotate the camera.

TODO: Add gamepad support for menus

## Animate Pickup Collected

To add a little bit of polish to the game, I decided to animate the pickups when they're collected.

To keep things simple, I decided to use the `Tween` node to animate the scale of the pickup.

First I added a tween_capture method to the `player.gd` script:

```gdscript
func tween_capture(body : Node) -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(body, "global_position", self.global_position, 0.2)#\
		#.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(body, "scale", Vector3.ZERO, 0.2)
	tween.set_parallel(false)
	tween.tween_callback(body.queue_free)
```

Next I updated the `_on_area_entered` method to call the tween_capture method:

```gdscript
func _on_area_entered(body : Node) -> void:
	if body.is_in_group("pickups"):
		count += 1
		set_count_text()
		tween_capture(body)
		# body.queue_free() # <-- this is no longer needed, it's called by the tween
```

And that's it. The pickups now animate when they're collected.

## Improve Pickup Visuals

I decided to improve the visuals of the pickups by adding a glow effect.

I just added a `OmniLight3D` node to the `pickup.tscn` scene, and set the following properties:

![Pickup OmniLight3D](images/pickup_glow.png)

Another thing I wanted was to have particles around the pickups, so I added a `GPUParticles3D` node to the `pickup.tscn` scene, and set the following properties:

- Increased the `Amount` to 16
- Set `Draw Passes` 1 to a `SphereMesh`
- Set a Material to the `SphereMesh`:
- ![Pickup GPUParticles3D](images/pickup_particle_material.png)
- Set a Process Material to the `GPUParticles3D`:
- ![Pickup GPUParticles3D](images/pickup_particle_process_material.png)

And that pretty much did it. The pickups now have a nice glow effect and particles around them.

## Animate Player Death

To put it simply, I just added a `GPUParticles3D` node to the `player.tscn` scene, and managed both it's emitting property and the ball's visibility.

Two key differences from the `Pickup` particles are the properties `One Shot` and `Explosiveness`. The first prevents the Particles animation from repeating, and the seconds spawns all the particles at once.

After that, I just enable to particles on death, hide the ball mesh and reset the ball rotation.

```gdscript
func _on_area_entered(body : Node) -> void:
	(...)
	if body.is_in_group("death_areas"):
		rotation = Vector3.ZERO # <- To ensure the particles are in the correct direction
		mesh_instance.visible = false
		death_particles.emitting = true
		(...)
```

Finally, on the `_on_continue_button_pressed`, we also need to display the ball mesh again.

```gdscript
func _on_continue_button_pressed() -> void:
	mesh_instance.visible = true
	(...)
```

This is a nice hack, but still a hack. After creating a proper spawn system, many of these things won't be needed.

## Adding a Pause Menu

It was actually very simple. The planned `Pause Screen` was just a variation of the `Defeat Screen` that I already had.

To better organize the code, I created three new methods:

```gdscript
func set_victory_screen() -> void:
	message_label.text = "You Win!"
	message_label.visible = true
	menu_container.visible = true

	restart_button.visible = true
	next_level_button.visible = true
	continue_button.visible = false
	quit_button.visible = true

	quit_button.grab_focus()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	freeze = true


func set_defeat_screen() -> void:
	# Death Animation
	rotation = Vector3.ZERO
	mesh_instance.visible = false
	death_particles.emitting = true

	message_label.text = "You Lose!"
	message_label.visible = true
	menu_container.visible = true

	restart_button.visible = true
	next_level_button.visible = false
	continue_button.visible = true
	quit_button.visible = true

	continue_button.grab_focus()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	freeze = true


func set_pause_screen() -> void:
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
```

I know there's a lot of duplicated code. I plan to refactor it later, when I separate the `HUD` into its own scene.

Next I updated the code to call the new methods. First the `set_count_text` method:

```gdscript
func set_count_text() -> void:
	if not count_label:
		return
	count_label.text = "Remaining: %s" % (total_pickups - count)

	if count >= total_pickups:
		set_victory_screen() # <-- call the new method
```

Then the `_on_area_entered` method:

```gdscript
func _on_area_entered(body : Node) -> void:
	if body.is_in_group("pickups"):
		count += 1
		set_count_text()
		tween_capture(body)

	if body.is_in_group("death_areas"):
		set_defeat_screen() # <-- call the new method
```

Then I updated the `_input` method. Instead of quitting the game, I now call the `set_pause_screen` method:

```gdscript
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# get_tree().quit()
		set_pause_screen() # <-- call the new method
```

But now there are two problems:

1. Pressing the `Continue` button resets the player's position, even if the player didn't die.
2. Unpausing the game resets the player's velocity, due to the `freeze` variable.

To address these issues, we need to change a few things on the `_on_continue_pressed` method. We need a way to know if the player died or not, and also store the player's velocity before pausing the game.

First we add two new variables to the `player.gd` script:

```gdscript
(...)
var player_dead : bool = false
var last_velocity : Vector3 = Vector3.ZERO
(...)
func _ready() -> void:
(...)
```

Then we update the `_on_area_entered` method to set the `player_dead` variable to `true`:

```gdscript
func _on_area_entered(body : Node) -> void:
	if body.is_in_group("pickups"):
		count += 1
		set_count_text()
		tween_capture(body)

	if body.is_in_group("death_areas"):
		player_dead = true # <-- set the new variable
		set_defeat_screen()
```

Then we update the `_input` method to store the player's velocity before pausing the game:

```gdscript
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# get_tree().quit()
		last_velocity = linear_velocity # <-- store the player's velocity
		set_pause_screen()
```

Then we update the `_on_continue_pressed` method to check if the player died or not, and restore the player's velocity if needed:

```gdscript
func _on_continue_button_pressed() -> void:
	(...)
	freeze = false

	if player_dead:
		position = spawn_position
		player_dead = false
	else:
		linear_velocity = last_velocity
		last_velocity = Vector3.ZERO # <-- reset the variable, just to be sure
```

And that's it. The pause menu is now working as expected.

It's a little hacky, but it works. I plan to refactor it later, when I separate the `HUD` into its own scene. With a proper respawn system, both the `player_dead` and `last_velocity` variables will be obsolete (we won't use `freeze` anymore).