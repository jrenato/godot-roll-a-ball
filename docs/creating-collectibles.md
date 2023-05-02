# Creating Collectibles

Unity's tutorial uses a simple, rotated cube as collectible.

## Mesh and Material

First, I created a `MeshInstance3D` with a `BoxMesh` scaled to 0.5 x 0.5 x 0.5.

Then I positioned the Mesh right beside the ball to see how it looked and rotated it by 45 x 45 x 45.

Finally, I added a `StandardMaterial` with an albedo of 255 200 0 and roughness of 0.75

## Collectible Rotation

The Unity's approach was to attach a script to the collectible that rotates it around by 15 x 30 x 45 degrees multiplied by `Time.deltaTime`.

```csharp
void Update () 
	{
		transform.Rotate (new Vector3 (15, 30, 45) * Time.deltaTime);
	}
```

In Godot, I could rearrange the nodes and have a `AnimationPlayer` as a child of the `MeshInstance3D` and animate the rotation, but I wanted it to be as close to the Unity's approach as possible.

So I used `Save Branch as Scene` to extract the Collectible into a separate scene, saved it as `levels/collectible.tscn` and added a `Script` to it.

```gdscript
extends MeshInstance3D

var rotation_vector : Vector3 = Vector3(15, 30, 45)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	rotation += rotation_vector * delta * 0.1
```

I had to multiply it by 0.1 or the rotation would be too fast.

I also tested the solution using a `Tween` to animate the rotation, but the result was the same with just more code.

```gdscript
extends MeshInstance3D

var rotation_vector : Vector3 = Vector3(15, 30, 45)

func _ready() -> void:
	tween_rotate_loop()

func tween_rotate_loop():
	var tween := create_tween()
	tween.tween_property(self, "rotation", rotation_vector, 5.0)
	tween.tween_callback(tween_rotate_loop)
```

The 5.0 is the duration of the animation in seconds.

Unfortunately, both solutions resulted in an animation quite different from the Unity's tutorial. My guess for now is that it's a pivot point issue.

I plan to research this issue in the future.

## Pickup Detection

In Godot, the first decision is if I want it to have physics or not.

If I want it to have physics, I can use a `CharacterBody3D` or a `RigidBody3D`. The former is more appropriate, since I don't need it to have full physics, just to be able to collide with the player. The latter would more appropriate if I wanted it to be able to fall off the platform, for example.

But even so it feels like overkill. I don't need it to have physics, I just need it to be able to collide with the player. Not even that, I just need to be able to detect when the player is over or near it.

So the best approach is to use an `Area3D` with a `CollisionShape3D` as a child, and a `SphereShape3D` to detect when the player is near it.
