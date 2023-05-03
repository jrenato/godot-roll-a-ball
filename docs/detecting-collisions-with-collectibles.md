# Detecting Collisions with Collectibles

## Small Update on Collectible

One thing I noticed is that there's no collision between the player and the collectibles.

I can fix that by refactoring the Collectible scene to be a `CharacterBody3D` with a `CollisionShape3D`, and having the `MeshInstance` as a child node of CharacterBody3D.

And I'll do that, although I don't think that's necessary. I initially planned to have the Player to have an `Area3D` node and use it to detect not collisions, but the proximity of the collectibles.

I'll possibly do that as an improvement on the game later, but for now, I'll keep it as close as possible to the original tutorial.

After refactoring the Collectible scene and its script, moving on.

## Collision Detection

The first three lessons of Unity's Roll-a-Ball tutorial do the following:

1. The player detects collisions with any object and disables it.
2. The Collectible Prefab is tagged as a pickup.
3. Finally, in the player script, a condition is added to check if the object is a pickup.

For the first part, I found out that `RigidBody3D` has a method called [get_colliding_bodies](https://docs.godotengine.org/en/latest/classes/class_rigidbody3d.html#class-rigidbody3d-method-get-colliding-bodies) that returns an array of bodies that are colliding with the current body.

It requires (contact_monitor)[https://docs.godotengine.org/en/latest/classes/class_rigidbody3d.html#class-rigidbody3d-property-contact-monitor] to be enabled (it's disabled by default), and `max_contacts_reported` to be set to a value greater than 0, so it can emit signals when it collides with another body.

With that, I could check all the colliding bodies in the Player's `_physics_process` method and check if it's a collectible.

```gdscript
func _physics_process(delta: float) -> void:
	var bodies : Array[Node3D] = get_colliding_bodies()
	for body in bodies:
        print(body)
```

Since apparently doesn't have an equivalent to Unity's `SetActive`, I'm just printing the collectible's id for now.

This will work, but print a lot of collisions, specially the floor. So it's time to proceed with the second part.

## Tagging Collectibles

Just like Unity, Godot has a way to tag objects. It's called [Groups](https://docs.godotengine.org/en/latest/tutorials/scripting/groups.html) and I believe it's exactly the same as Unity's tags.

So I added the `Collectible` to a group called `collectibles` and moved on.

## Checking if it's a Collectible

I was quite easy to check if the body is a collectible. I just had to check if the body is in the `collectibles` group.

```gdscript
func _physics_process(delta: float) -> void:
	var bodies : Array[Node3D] = get_colliding_bodies()
	for body in bodies:
		if body.is_in_group("collectibles"):
			print(body)
```

Before proceeding to the next lesson, I wondered if iterating through all the colliding bodies during physics processing was the best way to do it. Maybe there was a specific signal that I could use whenever a body collides with another.

And it turns out there is.

Checking the Godot's documentation on `RigidBody3D` again, I found out there's a signal called [body_entered](https://docs.godotengine.org/en/latest/classes/class_rigidbody3d.html#class-rigidbody3d-signal-body-entered) that is emitted when a body collides with another.

So I commented out the `_physics_process` code and added a method to handle the signal.

```gdscript
func _on_body_entered(body : Node) -> void:
	if body.is_in_group("collectibles"):
		print(body)
```

Reading more about [Signals](https://docs.godotengine.org/en/latest/getting_started/step_by_step/signals.html), I understood that I could connect a signal to a method using the editor (and the editor would create the method for me), but I decided to do it in code.

```gdscript
func _ready() -> void:
	body_entered.connect(_on_body_entered)
```
 
The result is the same, but I think it's better to use signals instead of iterating through all the colliding bodies.

## Collision problem

The next two lessons in Unity's tutorial are about setting the pickup as a trigger and adding a rigidbody to it. As far as I understand, the reason for the trigger is to avoid the player to push or be stopped by the pickup.

Without it, the player would collide with the pickup and just stop moving. It should just pass through it.

And that became a problem in Godot. The closest thing to a trigger I could think of was the `Area3D` node, but would it trigger the `body_entered` signal or be included in the `get_colliding_bodies` method?

I decided to test it. Added an `Area3D` node with a `CollisionShape3D`, and added it to the `collectibles` group.

The Player didn't detect the collision, it didn't print anything about it.

## Collision Layers and Masks

After deleting the testing `Area3D` node, I decided to try something else. What would happen if I tweaked the collision layers?

So far I didn't change anything about them, so all the collision layers and masks were set to the default values. I simply disabled the `Collectible` layer 1 and voilà, it worked.

But why? I don't know. I'll have to read more about collision layers and masks to understand it. My guess, considering it's name, is that `body_entered` only cares about overlapping occurrences between Physics nodes, and ignores the layer/mask settings.

Anyway, I'll keep it as it is for now, but will definitely come back to it later, since I don't think it's the best way to do it, it feels like a hack.

Next, it's time to move to [Displaying Score and Text](docs/displaying-score-and-text.md).