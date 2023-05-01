# Moving the Player

The first thing the Unity tutorial does is to add a `Rigidbody` component to the player.

This is the first big difference between Unity and Godot: while in Unity the Rigidbody is a component, in Godot it's a node.

Reading the [Physics introduction](https://docs.godotengine.org/en/latest/tutorials/physics/physics_introduction.html) in the Godot documentation, I found out that there are three types of physics nodes:

* [StaticBody3D](https://docs.godotengine.org/en/latest/classes/class_staticbody3d.html)
* [RigidBody3D](https://docs.godotengine.org/en/latest/classes/class_rigidbody3d.html)
* [CharacterBody3D](https://docs.godotengine.org/en/latest/classes/class_characterbody3d.html)

The `RigidBody3D` is the closest to the Unity `Rigidbody`, so I'll use it.

## Adding the RigidBody3D node

1. Add a RigidBody3D node to the root node
2. Drag the MeshInstance3D node to the RigidBody3D node to make it a child
3. Rename the MeshInstance3D back to MeshInstance3D
4. Reset the Transform property of the MeshInstance3D node back to `0.0, 0.0, 0.0`
5. Rename the RigidBody3D node to `Player`
6. Set the Transform property of the Player node to `0.0, 0.5, 0.0`

Unity's RigidBody has a Collision Detection attribute that is set to Discrete by default, so I presume that is enough for collision detection.

But Godot requires a CollisionShape3D node to be added to the RigidBody3D node to detect collisions. There's even a warning in the RigidBody3D node:

> This node has no shape, so it can't collide or interact with other objects. Consider adding a CollisionShape3D or CollisionPolygon3D as a child to define its shape.

So I added a CollisionShape3D node to the Player node and set its Shape property to SphereShape3D. I checked that both the SphereMesh and the SphereShape3D have a radius of 0.5m.

## Input

The next lessons in the Unity tutorial are about installing Input System package, setting up the input actions and creating a script to move the player.

Again, things are not exactly the same in Godot, but they're very easy to do.

### Input Map

1. Open the Project Settings
2. Select the Input Map tab