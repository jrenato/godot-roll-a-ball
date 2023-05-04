# Top Priorities

## Pickup Animation

This was a bit tricky. A challenge. Apparently it's a problem of local and global rotation.

I read the docs throughly and found these methods:

* [`rotate(Vector3 axis, float angle)`](https://docs.godotengine.org/en/latest/classes/class_node3d.html#class-node3d-method-rotate) - Rotates the local transformation around axis, a unit Vector3, by specified angle in radians.
* [`rotate_object_local(Vector3, float)`](https://docs.godotengine.org/en/latest/classes/class_node3d.html#class-node3d-method-rotate-object-local) - Rotates the local transformation around axis, a unit Vector3, by specified angle in radians. **The rotation axis is in object-local coordinate system**.

I'm not sure I understand it completely, but I got it working. Using `rotate` I got the same result as before, but using `rotate_object_local` I got the desired result.

This is the final code (for now):

```gdscript
extends CharacterBody3D

@onready var mesh_instance_3d : MeshInstance3D = $MeshInstance3D

var rotation_speed : float = 0.8


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	mesh_instance_3d.rotate_object_local(Vector3(1, 0, 0), 1 * delta * rotation_speed)
	mesh_instance_3d.rotate_object_local(Vector3(0, 1, 0), 2 * delta * rotation_speed)
	mesh_instance_3d.rotate_object_local(Vector3(0, 0, 1), 3 * delta * rotation_speed)
```

It became clear that I need to understand the difference between local and global coordinates. I'll do some research on that in the future.

## Improving the lighting

Unity's lighting:
![Unity's lighting](./images/unity_lighting.png)

Godot's lighting:
![Godot's lighting](./images/godot_lighting.png)

Looking at these, it seems to me that the Godot's lighting is not only brighter, but also prettier.

Anyway, I'll try to darken it a bit.

So, for starters, I reduce the `DirectionalLight3D`'s `energy` to `0.5`.

The result:
![Godot's lighting](./images/godot_lighting_2.png)

Closer, but still off.

So I changed the `DirectionalLight3D`'s `color` to 200 200 200.

The result:
![Godot's lighting](./images/godot_lighting_3.png)

Still not there, but I think it's good enough for now.

## Refactoring the Pickup collect

I don't believe the Pickup needs to be a `CharacterBody3D` node and having the Player checking for collisions (which requires the collision layer hack). It could be just an overlap check between `Areas 3D`.

This sounds like it'll be a fun thing to do.