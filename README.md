# Godot Roll-a-Ball

This is a simple game made with Godot Engine 4.0.3 rc1.

It's roughly based on the Unity Roll-a-Ball tutorial.

## Setting up

* [Setting up](docs/setting-up.md)
* [Moving the player](docs/moving-the-player.md)
* [Moving the camera](docs/moving-the-camera.md)
* [Setting up the play area](docs/setting-up-the-play-area.md)
* [Creating Collectibles](docs/creating-collectibles.md)
* [Detecting Collisions with Collectibles](docs/detecting-collisions-with-collectibles.md)
* [Displaying Score and Text](docs/displaying-score-and-text.md)
* [Building the Game](docs/building-the-game.md)

## To Do

### Improvements

- [x] Improve the `Pickup` animation, try to make it more similar to the Unity's one. (details [here](docs/improvements.md#pickup-animation))
- [x] Improve the lighting. It's certainly brighter than the Unity's one. (details [here](docs/improvements.md#improving-the-lighting))
- [x] Refactor the way the `Pickup` collect is handled. (details [here](docs/improvements.md#refactoring-the-pickup-collect))
- [x] Refactor the way the win condition is handled. (details [here](docs/improvements.md#refactoring-the-win-condition))

So I consider this build to be the first version of the game, and I'll call it `v1.0.0`, since it's very close to the Unity's one, with just a few improvements and tweaks.

It can be downloaded [here](https://github.com/jrenato/godot-roll-a-ball/releases/tag/1.0.0).

After this, I'll start working on the next improvements:
### Medium Priorities

- [x] Add camera controls (details [here](docs/medium-priorities.md#camera-controls))
- [x] Replace the `Ground` and `Walls` with a modular gridmap and expand the level (details [here](docs/medium-priorities.md#modular-gridmap))
- [x] Have the `Player` be destroyed when it falls off the level (details [here](docs/medium-priorities.md#player-death-and-respawn))
- [ ] Add an win/lose screen with options to restart and exit the game. (details [here](docs/medium-priorities.md#losing-and-restarting-the-level))
- [ ] Add a pause menu with options to restart the game and exit the game.
- [ ] Add another type of pickup.
- [ ] Add a `Tween` to the `Player` when it's destroyed.
- [ ] Add a `Tween` to the `Pickup` when it's collected.
- [ ] Add sounds.

### Low Priorities

- [ ] Refactor the things I don't think belong to the `Player` script.
- [ ] Add a main and settings menu.
- [ ] Add a level selection menu and create more levels.
- [ ] Add state to the game, keeping track of the collected pickups and the time it took to complete the level.
- [ ] Add a `Ramp` to create verticality on level design
- [ ] Add a `Coil` object that launches the player in the air for more verticality
- [ ] Damaging Walls and Floors that can destroy the player.
- [ ] Destructible walls
