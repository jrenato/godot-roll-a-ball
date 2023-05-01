# Moving the Camera

Unity's tutorial attaches a script to the camera to make it follow the player. We can do the same thing in Godot.

First I renamed the camera to GameCamera extracted it from the level scene and saved it as `res://level/game_camera.tscn`.

Then I attached a script to the camera and saved it as `res://level/game_camera.gd`.

```gdscript
extends Camera3D

@export var player: RigidBody3D

var offset : Vector3


func _ready() -> void:
	if player:
		offset = global_position - player.global_position


func _process(delta: float) -> void:
	if player:
		global_position = player.global_position + offset
```

Then, in the level scene, I set the `player` property of the camera to the Player node.

Just like before, Unity's tutorial uses a public variable to store a player reference. In Godot, we use the `export` keyword to make a variable editable in the inspector.

Also, it results in a static, slightly boring camera. I'll try to tackle later.

For now, let's move on to the next step, [Setting up the Play Area](setting-up-the-play-area.md).