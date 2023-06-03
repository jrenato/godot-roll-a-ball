# Low priorities

## Add a `Ramp` to create verticality on level design

After learning that it's not possible to add [CSG nodes to a Gridmap](https://www.reddit.com/r/godot/comments/ovfh6y/am_i_able_to_make_a_gridmap_with_csg_nodes/), even though it's possible to create it using other methods, I decided to just create a CSGPolygon and use it as a ramp.

![Ramp](images/ramp_object.png)

## Add a `Coil` object that launches the player in the air for more verticality

I wanted something very simple: an `Area3D` that detects the `Player` and launches it in the air.

I created a `Coil` scene with an `Area3D` as root and a `CollisionShape` as children. I also added two MeshInstances, PadMesh and CoilMesh, to make it look like a coil.

I set all of their meshes and shape as Cylinders, and set their radius, height and transform as needed.

Finally I added an `AnimationPlayer` to the `Coil` scene and attached a script to the root node.

```gdscript
extends Area3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var force: int = 800


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.apply_central_force(Vector3.UP * force)
		animation_player.play("trigger")
		animation_player.queue("rearm")
```

The `trigger` and `rearm` animations are very simple, and basically mirror each other: they just move the pad slightly up and down and resize the coil.

![Coil](images/coil_armed.png)

![Coil](images/coil_triggered.png)

Finally, the `Player` is launched in the air by using `apply_central_force` on the `body` parameter of the `_on_body_entered` function, multiplying the `Vector3.UP` by the `force` property.