# Displaying Score and Text

Before starting, there's one thing that's bothering me: what I call a `Collectible` is actually a `Pickup` in Unity's tutorial. Although the menus refer to them as collectibles, on the videos and code it's pickups.

I decided to rename everything to `Pickup` to avoid confusion, including the scene, the script and the group. You can check the commit [here](https://github.com/jrenato/godot-roll-a-ball/commit/dc40002a976db2ae8fa85bf0254df47b40564a75).

For now, I won't change the documentation, otherwise the text above will be outdated. Maybe I'll change it later.

Withou further ado, I'll start working on the score and text.

## Store the value of collected PickUps

The Unity's tutorial added a private variable named `count` to store the value of the collected pickups.

One thing I wondered is that there are no private variables in GDScript. I searched for it and found out it's been [discussed before](https://github.com/godotengine/godot/issues/18411) and that there's even a [proposal](https://github.com/godotengine/godot-proposals/issues/641) for it.

But would that even be important here? As far as I understood, the main reason it's a private variable on the Unity's tutorial is to hide it on the inspector.

In Godot, all I have to do is to avoid the @export keyword and it won't be visible on the inspector. So, I'll just do that.

```gdscript

var count : int
```

I could initialize it with `0`, but I'll keep it the way Unity's tutorial does and initialize it on `_ready()`.

```gdscript
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	count = 0 # <- here
```

Finally, I'll update the `_on_body_entered()` function to increment the count.

```gdscript
func _on_body_entered(body : Node) -> void:
	if body.is_in_group("pickups"):
		count += 1 # Or count = count + 1, as in Unity's tutorial
		body.queue_free()
```

## Create a UI text element

As far as I understood, Unity uses a library called TextMesh Pro to create the text elements.

Since Godot has built-in nodes for user interface, things will probably be easier here.

One consideration: Unity's tutorial adds the UI elements directly on the Player scene. Usually I'd prefer to create a separate scene for the UI, and keep count and other game related stuff on a higher level scene. But since this is a small project, and the idea here is to keep it as close as possible to the Unity's tutorial, I'll add the UI elements directly on the Player scene as well.

So, in Player.tscn, I added a `CanvasLayer` node and a `Label` node as a child of it. I renamed the label to `CountLabel` and set its text to `Count Label`. The Unity's tutorial set its anchor to the top left corner, but that's already the default in Godot, so I didn't have to change anything.

On the other hand, the `CountLabel` font is too small, so I increased its font size to `24`. Also, the node is too close to the top left corner. That required some extra consideration. The Unity's tutorial changed its transform to position it further down and right, but I didn't want to do that. It feels like a hack.

Instead, I added a `MarginContainer` node as a child of the `CanvasLayer` and overrided all of its margins constants to `20`. Then, I moved the `CountLabel` as a child of the `MarginContainer` and the problem was solved.

## Display the count value

Unity's tutorial followed these steps to display the count value:

1. Imported the `TMPro` namespace into the player script
2. Added a `TextMeshProUGUI` public variable called `countText`
3. Created a `SetCountText()` function to update the text
4. Called `SetCountText()` on `Start()`
5. Called `SetCountText()` after incrementing the count
6. Finally, dragged the `CountText` node to the `countText` variable on the inspector

I'll do it following the same steps, but later on I'll try to simplify it.

Step 1: added a reference to the `Label` node on the player script.
```gdscript
@export var count_label: Label
```

Step 2: created a `SetCountText()` function to update the text.
```gdscript
func set_count_text() -> void:
	count_label.text = "Count: %s" % count
```

Instead of just concatenating the count to the string, I prefer to use a [format string](https://docs.godotengine.org/en/latest/tutorials/scripting/gdscript/gdscript_format_string.html). I think it makes it easier to read the code.

Step 3: called `SetCountText()` on `_ready()`.
```gdscript
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	count = 0
	set_count_text()
```

Step 4: called `SetCountText()` after incrementing the count.
```gdscript
func _on_body_entered(body : Node) -> void:
	if body.is_in_group("pickups"):
		count += 1
		set_count_text()
		body.queue_free()
```

Step 5: dragged the `CountLabel` node to the `count_label` variable on the inspector.

One thing I added on my own, and I think it's an important thing to do, is to check if the `count_label` variable is not null befere accessing it. That's because if I forget to drag the node to the variable on the inspector, the game will crash.

```gdscript
func set_count_text() -> void:
	if not count_label:
		return
	count_label.text = "Count: %s" % count
```

There might be more places in the code where I should do that I forgot to do it, and I might look for them later.

Another thing I won't change, but I want to register it here, is that I actually didn't need to drag the `CountLabel` node to the `count_label` variable on the inspector. 

I could just use an @onready variable instead, like this:

```gdscript
@onready var count_label: Label = $CanvasLayer/MarginContainer/CountLabel
```

It's even possible to simplify it further, by enabling "Access By Unique Name" on the `Label` node, and then using this:

```gdscript
@onready var count_label: Label = %CountLabel
```

Another neat feature of Godot is that I don't even need to write this code. I could just drag the node from the inspector to the script and holding the `Ctrl` key before releasing it. That would automatically create an @onready variable for me.

But I won't do any of those things yet, because I want to keep it as close as possible to the Unity's tutorial.

## Create a game end message

That's another thing that's doesn't belong to the Player scene, but anyway, I added a second `MarginContainer` node as a child of the `CanvasLayer` and a `Label` node as a child of it. I renamed the label to `WinLabel` and set its text to `You Win!`.

Unity's tutorial set its anchor to the center, so I changed the `Anchors preset` attribute of the `MarginContainer` to `Center Top`. Then I added a top margin of `200` to the `MarginContainer` to position the `WinLabel` roughly in the same place as in the Unity's tutorial.

Finally, I set the color of the `WinLabel` to black to match the Unity's tutorial, but I also added a white shadow to it, because I think it looks better when the background is dark.

Proceeding to the next step, I added a reference to the `WinLabel` node on the player script named `win_label`.

```gdscript
@export var win_label: Label
```

And I set it in the inspector.

Finally, Unity checks the condition to victory in `SetCountText()`, so I'll do the same here.

```gdscript
func set_count_text() -> void:
	if not count_label:
		return
	count_label.text = "Count: %s" % count

	if not win_label:
		return

	if count >= 12:
		win_label.visible = true
```

One consideration before moving on: I know it's a simple project, but hardcoding the number of pickups required to win is not a good idea. I think it's a simple thing to improve, instead of hardcoding the number of pickups, calling a method to check all the instanced nodes in the `pickups` group and counting them would be better.

Even better, maybe creating a variable to store the number of pickups and set it only once on the `_ready()` method. Then I'll just compare the count to that variable.

But that's not what the Unity's tutorial does, so I'll keep it the way it is for now, and proceed with [Building the Game](building-the-game.md)