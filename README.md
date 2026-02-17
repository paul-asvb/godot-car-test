# Godot Car Test

A 3D car physics demo built with Godot 4.5+ using the Forward Plus renderer.

## Controls

- **Arrow Up** - Accelerate
- **Arrow Down** - Brake/Reverse
- **Arrow Left** - Steer left
- **Arrow Right** - Steer right

## Running

```bash
godot
```

Or run the main scene directly:

```bash
godot scenes/main.tscn
```

## Project Structure

```
├── scenes/main.tscn          # Main gameplay scene
├── entities/car/car.gd       # Vehicle physics (RigidBody3D + ray-cast suspension)
├── entities/obstacles/       # Moving obstacle entities
├── project.godot             # Project configuration
└── AGENTS.md                 # Development documentation
```

## Car Physics

The car uses a custom suspension system:
- RayCast3D for each wheel to detect ground contact
- Spring-damper model for suspension
- Rear-wheel drive
- Lateral grip to prevent sliding

## License

MIT
