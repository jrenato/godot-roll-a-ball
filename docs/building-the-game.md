# Building the Game

The process of building the game in Godot is certainly way, way different than Unity, so I'll take the liberty of ignoring the Unity's tutorial and doing it directly in Godot.

But before, I'll do a small, quick change to the game.

## Adding a way to exit the game

One thing I think this is a good moment to do is improve the way to exit the game. Currently, the only way is by closing the window or pressing `Alt + F4`.

I'll keep it simple for now and just read the `ui_cancel` input event and call `get_tree().quit()`.

```gdscript
func _input(event : InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_tree().quit()
```

And that's it. Now I can exit the game by pressing `Esc`.

## Installing the export templates

The first step is to install the export templates. It's actually pretty simple.

On the main menu, I just had to go to `Editor > Manage Export Templates...`, and download the templates package for version I'm using (currently 4.0.3 rc1).

## Exporting the game

Then, I just had to go to `Project > Export...`, click the `Add...` button, select the platform I want to export to, and click `Export Project`.

A few notes:
* The `Windows Desktop` option displays a message regarding a tool called `rcedit`. As far as I know, it's important to change the icon of the executable file, but I'll just ignore it for now.
* I change the `Export Console Script` option from `Debug` to `No`.
* I enabled the `Embed PCK` option. If there's any problem with this, I'll disable it and rebuild it.

And that's it for now.