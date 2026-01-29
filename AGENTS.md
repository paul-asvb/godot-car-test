# Godot Agent Guidelines

This documentation helps AI agents work effectively in this Godot 4.x project.

## Project Structure
- **Framework**: Godot 4.5+ (uses "Forward Plus" renderer)
- **Language**: GDScript (`.gd`)
- **Main Scene**: `scenes/main.tscn`

```
/                           # Project root
├── scenes/                 # Scene files (.tscn)
│   └── main.tscn          # Main gameplay scene
├── entities/              # Game entities (scripts + related assets)
│   ├── car/               # Car entity
│   │   └── car.gd         # Vehicle physics script
│   └── obstacles/         # Obstacle entities
│       └── moving_obstacle.gd
├── project.godot          # Main project configuration
└── AGENTS.md              # This file
```

## Key Files
- `project.godot`: Main project configuration.
- `scenes/main.tscn`: The primary gameplay scene containing the environment and the car.
- `entities/car/car.gd`: Script controlling the vehicle physics (attached to `RigidBody3D`).
- `entities/obstacles/moving_obstacle.gd`: Script for moving obstacles.

## Commands
*These commands assume `godot` is in the system PATH.*

- **Run Project**: `godot` (opens project manager or runs project if arguments provided)
- **Run Main Scene**: `godot scenes/main.tscn`
- **Headless Mode** (useful for CI/testing): `godot --headless`

## Code Conventions (GDScript)
- **Style**:
  - `snake_case` for variables and functions.
  - `PascalCase` for classes and nodes.
  - `SCREAMING_SNAKE_CASE` for constants (e.g., `SPEED`, `ROT_SPEED`).
- **Physics**:
  - Uses `move_and_slide()` with `CharacterBody3D`.
  - Logic is in `_physics_process(delta)`.
  - **Important**: In Godot 3D, negative Z (`-basis.z`) is the forward direction.

## Scene Hierarchy (`main.tscn`)
- `Main` (Node3D)
  - `DirectionalLight3D`
  - `Ground` (StaticBody3D)
  - `Car` (CharacterBody3D) - *Controlled by `car.gd`*
    - `Camera3D`
    - `CollisionShape3D`
    - `MeshInstance3D`

## Gotchas
- **Implicit Types**: GDScript is dynamically typed. Explicit typing (e.g., `var x: int = 0`) is encouraged but not strictly enforced in current files.
- **File UIDs**: Godot 4 uses `uid="..."` in `.tscn` and `.gd.uid` files to track resources. Moving files outside the editor can break these references.
- **Hidden Configs**: The `.godot/` directory contains internal cache/import data and should generally be ignored by Git (add to `.gitignore` if missing).
