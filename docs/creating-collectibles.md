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

Unfortunately, both solutions resulted in an animation quite different from the Unity's tutorial. My guess for now is that it might be a pivot point issue.

I plan to research this issue in the future.

## Instantiating Collectibles

The next two lessons in the Unity's tutorial are about making the Collectibles a Prefab and instantiating it in the scene.

I understand that a Prefab is a way to reuse a set of nodes and their properties in multiple scenes, so I actually already did that when I extracted the Collectible into a separate scene in order to attach a script and animate it.

That way, I can just more `Collectible` nodes to the scene and it will be just like the Unity's tutorial.

But before that, the Unity's tutorial creates an Empty GameObject called `Pickup Parent` to hold all the Collectibles. I'll do the same using a `Node3D` called `Collectibles`.

Then I'll duplicate some `Collectible` nodes as children of `Collectibles` and position just like in the Unity's tutorial. One thing I was happy to find out is that, just like the Unity's tutorial, I can change the viewport to see the scene from different angles using the view gizmo.

Now I can proceed to [Detecting Collisions with Collectibles](detecting-collisions-with-collectibles.md).
