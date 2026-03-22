# Godot Kart Racing Game

A Mario Kart-style arcade racing game built with Godot 4.5+ using the Forward Plus renderer.

## Quick Start

Just run:

```bash
./run.sh
```

Or run the main scene directly:

```bash
godot scenes/main.tscn
```

## Controls

- **Arrow Up** - Accelerate
- **Arrow Down** - Brake/Reverse
- **Arrow Left** - Steer left
- **Arrow Right** - Steer right
- **Space** - Enter drift (while turning at speed)
- Release drift to activate boost (blue/orange/pink tiers based on drift duration)

## Features

Currently implemented (Phases 1-3):
- Arcade-style physics with CharacterBody3D
- Responsive steering and fast acceleration
- Drift system with lateral slide mechanics
- Three-tier boost system (0.5s/1.5s/3.0s drift times)
- Visual feedback: drift sparks, boost flames, speed lines
- Camera smooth following with drift offset

## Project Structure

```
├── scenes/main.tscn                  # Main gameplay scene
├── entities/car/arcade_car.gd        # Arcade-style kart physics
├── entities/obstacles/               # Moving obstacle entities
├── project.godot                     # Project configuration
├── AGENTS.md                         # Development documentation
└── run.sh                            # Quick launch script
```

## Physics System

Arcade-style kart physics:
- CharacterBody3D with velocity-based movement
- Raycast ground detection and surface alignment
- Mario Kart 8 inspired: fast acceleration, responsive steering
- Three-state machine: NORMAL/DRIFTING/BOOSTING
- Chain drifts and boosts for sustained speed

## License

MIT
