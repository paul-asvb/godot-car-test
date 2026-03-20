# Architecture Analysis

**Analyzed:** 2026-03-20
**Codebase:** Godot 4.5 3D Game

## Architectural Pattern

**Entity-Component-Scene Pattern (Godot native)**
- Scenes as compositional units
- Nodes as components
- Scripts as behavior extensions
- Tree-based hierarchy

**No MVC/MVVM:** Godot uses scene tree + signals, not traditional web patterns.

## System Layers

**1. Entry Layer**
- Menu scene (`scenes/menu.tscn`)
- Scene selection UI
- Navigation to gameplay scenes

**2. Gameplay Layer**
- Main scene (`scenes/main.tscn`)
- Car-only scene (`scenes/car_only.tscn`)
- Contains all gameplay entities

**3. Entity Layer**
- Car entity (`entities/car/`)
- Obstacle entities (`entities/obstacles/`)
- Self-contained components

**4. Physics Layer**
- Godot physics engine (built-in)
- Custom suspension logic in car script
- RigidBody3D, StaticBody3D, AnimatableBody3D

## Component Structure

**Scene Components:**
```
Menu (Control)
  └─ VBoxContainer
      ├─ Label (title)
      ├─ MainSceneButton
      └─ CarOnlyButton

Main (Node3D)
  ├─ DirectionalLight3D (lighting)
  ├─ Ground (StaticBody3D)
  ├─ Car (RigidBody3D) ← car.gd script
  │   ├─ Camera3D
  │   ├─ CollisionShape3D
  │   ├─ MeshInstance3D (body)
  │   └─ Wheel nodes (4x RayCast3D + mesh)
  ├─ Walls (Node3D container)
  ├─ Ramps (Node3D container)
  ├─ Boulders (Node3D container)
  ├─ Pillars (Node3D container)
  ├─ Bumps (Node3D container)
  └─ MovingObstacles (Node3D container)
      └─ Moving[N] (AnimatableBody3D) ← moving_obstacle.gd
```

## Data Flow

**Input → Physics → Rendering:**

```
1. Input System (Godot input actions)
   ↓
2. _input() / _physics_process(delta) in scripts
   ↓
3. Physics calculations (custom + engine)
   ↓
4. Force application (apply_force on RigidBody3D)
   ↓
5. Physics engine step
   ↓
6. Transform updates
   ↓
7. Rendering (automatic, engine-managed)
```

**Car Physics Pipeline:**
```
Input (arrow keys)
  ↓
Steering/throttle state update
  ↓
For each wheel:
  - RayCast collision detection
  - Suspension force calculation (spring + damper)
  - Tire grip force (lateral + drive)
  - Force application via apply_force()
  ↓
RigidBody3D physics step (engine)
  ↓
Position/rotation update
  ↓
Visual wheel mesh positioning
```

**Scene Transitions:**
```
Menu scene
  ↓ (button pressed)
get_tree().change_scene_to_file()
  ↓
Gameplay scene loaded
  ↓ (ESC pressed in car.gd)
get_tree().change_scene_to_file("res://scenes/menu.tscn")
  ↓
Back to menu
```

## Entry Points

**Application Entry:**
- `project.godot` defines: `run/main_scene="res://scenes/menu.tscn"`
- Godot engine loads menu scene first

**Scene Entry Points:**
- `scenes/menu.tscn` - Menu UI entry
- `scenes/main.tscn` - Main gameplay (full obstacle course)
- `scenes/car_only.tscn` - Simplified gameplay (car only)

**Script Entry Points:**
- `entities/car/car.gd` attached to Car node in main.tscn
- `entities/obstacles/moving_obstacle.gd` attached to Moving[N] nodes
- Menu script (inline in menu.tscn as GDScript resource)

## Key Abstractions

**Car (RigidBody3D):**
- Physics-driven vehicle
- Custom suspension via raycasts
- 4-wheel independent simulation
- Rear-wheel drive model

**MovingObstacle (AnimatableBody3D):**
- Kinematic obstacle (non-physics-driven)
- Sinusoidal motion along configurable axis
- @export parameters for customization

**Static Environment (StaticBody3D):**
- Ground, walls, ramps, boulders, pillars, bumps
- Non-moving collision geometry
- Procedural meshes + materials

## State Management

**Runtime State Only:**
- No persistent save/load
- Car state: position, velocity, angular velocity (RigidBody3D)
- Obstacle state: time accumulator, start position
- Scene state: current loaded scene

**State Reset:**
- Car resets position on out-of-bounds or flip (`reset_position()`)
- Scene reload resets all state (no persistence)

## Communication Patterns

**Scene Tree Signals:**
- Button signals connected to menu script methods
- `pressed` signal → `_on_main_scene_button_pressed()`

**Direct Node References:**
- `@onready` for child node caching
- `get_tree()` for global scene tree access

**Input Polling:**
- `Input.is_action_pressed()` in `_physics_process()`
- `event.is_action_pressed()` in `_input()`

**No Event Bus:** Simple enough for direct calls.

## Dependencies

**Car Dependencies:**
- 4x RayCast3D child nodes (wheel collision detection)
- 4x MeshInstance3D child nodes (visual wheels)
- Godot physics engine (RigidBody3D integration)

**Obstacle Dependencies:**
- AnimatableBody3D base class (kinematic body)
- Configurable via @export properties

**Menu Dependencies:**
- SceneTree for scene transitions
- Button nodes with signal connections

## Build Order Implications

**Logical Build Sequence:**
1. Static environment (ground, walls)
2. Static obstacles (ramps, boulders, bumps)
3. Moving obstacles (AnimatableBody3D entities)
4. Car physics (most complex, depends on environment)
5. Menu/UI (navigation layer)

**Actual Godot Build:**
- All scenes built simultaneously
- No compilation dependencies between .tscn files
- Scripts compiled on load (GDScript VM)

## Performance Characteristics

**Bottlenecks:**
- RigidBody3D physics (4 raycasts per frame)
- Force calculations per wheel (4x per frame)
- Procedural mesh generation (scene load only)

**Optimization Opportunities:**
- Wheel raycasts could be staggered (not critical for 4 wheels)
- Physics timestep adjustable via project settings
- LOD for distant obstacles (not currently implemented)

---
*Architecture documented: 2026-03-20*
