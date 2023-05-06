# Medium Priorities

## Add camera controls.

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

Honestly, I don't know if this is the best solution, but it works. I'll keep it for now.

## Replace the `Ground` and `Walls` with a modular gridmap and expand the level.

The level is very small, and it's not very interesting. It would be nice to have a bigger level, with more pickups and obstacles.