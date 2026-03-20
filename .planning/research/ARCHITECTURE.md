# Architecture Research

**Domain:** Arcade Kart Racing (Mario Kart-style)
**Researched:** 2026-03-20
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Layer (HUD, Menus)                   │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│   │RaceHUD P1│  │RaceHUD P2│  │RaceHUD P3│  │RaceHUD P4│   │
│   └─────┬────┘  └─────┬────┘  └─────┬────┘  └─────┬────┘   │
├─────────┴──────────────┴──────────────┴──────────────┴──────┤
│                    Game Logic Layer                          │
│  ┌────────────┐  ┌─────────────┐  ┌──────────────┐          │
│  │ Race       │  │ Powerup     │  │ Checkpoint   │          │
│  │ Manager    │  │ System      │  │ System       │          │
│  └──────┬─────┘  └──────┬──────┘  └──────┬───────┘          │
├─────────┴────────────────┴─────────────────┴─────────────────┤
│                   Entity Layer (Karts, Track)                │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐         │
│  │ Kart P1 │  │ Kart P2 │  │ Kart P3 │  │ Kart P4 │         │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘         │
├───────┴─────────────┴─────────────┴─────────────┴────────────┤
│                 Rendering Layer (SubViewports)               │
│  ┌──────────────────────┐  ┌──────────────────────┐          │
│  │   Viewport P1/P2     │  │   Viewport P3/P4     │          │
│  │  (split horizontal)  │  │  (split horizontal)  │          │
│  └──────────────────────┘  └──────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| **KartController** | Kart physics, drift state, boost state, input handling | CharacterBody3D script with state machine |
| **RaceManager** | Lap counting, position tracking, race state (countdown/racing/finished) | Autoload singleton or scene root script |
| **CheckpointSystem** | Validates lap progression, prevents shortcuts, tracks distance | Area3D nodes along track, RaceManager coordinates |
| **PowerupManager** | Item spawns, item effects, collision detection | Autoload singleton managing item state |
| **CameraController** | Smooth following, drift offset, FOV changes | Camera3D child of kart with smoothing logic |
| **RaceHUD** | Display lap, time, position, items | Control node per player, reads from RaceManager |
| **SplitscreenManager** | Viewport creation, input routing, performance management | Scene root script or autoload |

## Recommended Project Structure

```
godot-car-test/
├── systems/
│   ├── kart_controller/
│   │   ├── kart_controller.gd       # CharacterBody3D arcade physics
│   │   ├── drift_state_machine.gd   # Drift/boost state logic
│   │   └── kart_visuals.gd          # Wheel rotation, lean animations
│   ├── race_manager/
│   │   ├── race_manager.gd          # Autoload singleton for race state
│   │   ├── checkpoint_system.gd     # Lap validation
│   │   └── position_tracker.gd      # Calculate player positions
│   ├── powerup_system/
│   │   ├── powerup_manager.gd       # Autoload for item state
│   │   ├── item_box.gd              # Pickup trigger
│   │   └── items/
│   │       ├── speed_boost.gd
│   │       ├── projectile.gd
│   │       └── defensive_shield.gd
│   └── splitscreen/
│       ├── splitscreen_manager.gd   # Viewport setup
│       └── player_camera.gd         # Per-player camera logic
├── entities/
│   ├── kart/
│   │   ├── kart.tscn                # Kart scene (mesh + controller)
│   │   └── kart.gd                  # References KartController system
│   └── track_objects/
│       ├── item_box.tscn
│       └── checkpoint.tscn
├── tracks/
│   ├── track_01.tscn
│   ├── track_02.tscn
│   └── track_data/
│       ├── track_01_checkpoints.tres
│       └── track_02_checkpoints.tres
├── ui/
│   ├── race_hud/
│   │   ├── race_hud.tscn            # HUD for one player
│   │   └── race_hud.gd
│   ├── menus/
│   │   ├── main_menu.tscn
│   │   ├── track_select.tscn
│   │   └── results_screen.tscn
│   └── splitscreen_ui.tscn          # Container for multiple HUDs
├── effects/
│   ├── particles/
│   │   ├── drift_sparks.tscn        # GPUParticles3D
│   │   ├── boost_flames.tscn
│   │   └── speed_lines.tscn
│   └── trails/
│       └── tire_marks.gd            # MultiMeshInstance3D trail generation
├── audio/
│   ├── engine_sound.gd              # Pitch-shifted audio
│   └── sfx/
│       ├── drift.wav
│       ├── boost.wav
│       └── item_pickup.wav
└── scenes/
    └── race_scene.tscn              # Main racing scene (replaces main.tscn)
```

### Structure Rationale

- **systems/:** Reusable logic separated from entities - can be used across multiple karts/tracks
- **entities/:** Scene instances that use systems - kart scenes, track objects
- **tracks/:** Track designs - each track is self-contained scene
- **ui/:** All UI separated from game logic - easier to iterate on HUD design
- **effects/:** Visual feedback isolated - can swap particle designs without touching gameplay
- **audio/:** Sound management separate from game logic

## Architectural Patterns

### Pattern 1: Autoload Singletons for Global State

**What:** RaceManager and PowerupManager as autoloaded singletons
**When to use:** For state that needs to be accessed by multiple karts and UI
**Trade-offs:** Easy access vs. potential global state coupling

**Example:**
```gdscript
# autoload: RaceManager
extends Node

signal race_started
signal race_finished
signal lap_completed(player_id: int, lap: int, time: float)

var race_state := RaceState.COUNTDOWN
var players: Array[PlayerData] = []

func register_player(kart: Node3D, player_id: int):
    players.append(PlayerData.new(kart, player_id))

func update_player_checkpoint(player_id: int, checkpoint_id: int):
    # Update player progress, recalculate positions
    pass
```

### Pattern 2: Component Composition for Karts

**What:** Kart scene composes multiple components (controller, visuals, effects, audio)
**When to use:** When features need to be independently toggled or swapped
**Trade-offs:** Flexibility vs. more nodes to manage

**Example:**
```gdscript
# kart.tscn hierarchy
Kart (CharacterBody3D)
  ├── KartController (script)
  ├── KartVisuals (MeshInstance3D + script)
  ├── EffectsManager (Node3D)
  │   ├── DriftSparks (GPUParticles3D)
  │   ├── BoostFlames (GPUParticles3D)
  │   └── SpeedLines (GPUParticles3D)
  ├── AudioManager (Node)
  │   ├── EngineSound (AudioStreamPlayer3D)
  │   └── DriftSound (AudioStreamPlayer3D)
  ├── PlayerCamera (Camera3D)
  └── CollisionShape3D (CapsuleShape3D)
```

### Pattern 3: Signal-Based Communication

**What:** Systems communicate via signals rather than direct calls
**When to use:** Loose coupling between systems (UI updates, effects triggers)
**Trade-offs:** Easier to extend vs. harder to trace call flow

**Example:**
```gdscript
# KartController emits signals
signal drift_started
signal drift_tier_changed(tier: int)  # 0=none, 1=blue, 2=orange, 3=pink
signal boost_activated(boost_amount: float)

# EffectsManager listens
func _ready():
    kart_controller.drift_started.connect(_on_drift_started)
    kart_controller.drift_tier_changed.connect(_on_drift_tier_changed)

func _on_drift_tier_changed(tier: int):
    match tier:
        1: drift_sparks.color = Color.BLUE
        2: drift_sparks.color = Color.ORANGE
        3: drift_sparks.color = Color.PINK
```

## Data Flow

### Input Flow

```
[Player Input (keyboard/gamepad)]
    ↓
[SplitscreenManager routes by player_id]
    ↓
[KartController processes input]
    ↓
[DriftStateMachine updates state]
    ↓
[CharacterBody3D move_and_slide()]
    ↓
[Camera follows kart position]
```

### Race State Flow

```
[Kart passes through checkpoint]
    ↓
[Checkpoint Area3D detects body_entered]
    ↓
[CheckpointSystem validates sequence]
    ↓
[RaceManager updates player progress]
    ↓
[PositionTracker recalculates standings]
    ↓
[RaceHUD updates display via signals]
```

### Powerup Flow

```
[Kart overlaps ItemBox Area3D]
    ↓
[ItemBox.body_entered signal]
    ↓
[PowerupManager assigns random item to player]
    ↓
[RaceHUD displays item icon]
    ↓
[Player presses item button]
    ↓
[PowerupManager activates item effect]
    ↓
[Item spawns projectile OR applies effect to kart]
```

### Key Data Flows

1. **Input → Movement:** Player input → KartController → CharacterBody3D physics → position update
2. **Progress → UI:** Checkpoint → RaceManager → Position calculation → HUD update via signals
3. **State → Effects:** Drift state → Signal emission → Particle effects activation

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 1-2 players | Standard approach works fine, minimal performance concerns |
| 3-4 players | Must optimize: reduce particle counts, lower SubViewport resolution, consider LOD |
| Web build | Critical: profile early, optimize draw calls, limit audio streams |

### Scaling Priorities

1. **First bottleneck:** Rendering with 4 SubViewports - Solution: Lower viewport resolution, reduce particles
2. **Second bottleneck:** Physics with 4 karts + items - Solution: Simplify collision shapes, reduce item count

## Anti-Patterns

### Anti-Pattern 1: RigidBody3D for Arcade Karts

**What people do:** Use RigidBody3D with apply_force() for kart movement
**Why it's wrong:** Physics simulation fights arcade feel - adds inertia, unpredictable behavior, hard to tune
**Do this instead:** CharacterBody3D with move_and_slide() - direct control, predictable, easy to tune

### Anti-Pattern 2: Global Script Variables for Player State

**What people do:** Store player positions, laps, times in global script variables
**Why it's wrong:** Hard to reset between races, error-prone with multiple players, no encapsulation
**Do this instead:** PlayerData class instances managed by RaceManager singleton

### Anti-Pattern 3: Polling for Input in Each Kart

**What people do:** Each kart checks Input.is_action_pressed() for all possible players
**Why it's wrong:** Karts don't know which player controls them, input conflicts in splitscreen
**Do this instead:** SplitscreenManager routes input to correct kart based on player_id

### Anti-Pattern 4: One Giant Race Script

**What people do:** Put all race logic (lap counting, position tracking, UI, items) in one script
**Why it's wrong:** Unmaintainable, hard to test, tight coupling
**Do this instead:** Separate concerns - RaceManager, CheckpointSystem, PowerupManager, etc.

## Integration Points

### SubViewport Splitscreen Setup

**Pattern:** Create SubViewport for each player, assign camera, render to screen region
```gdscript
# 2-player horizontal split
viewport_1 = SubViewport.new()
viewport_1.size = Vector2i(screen_width, screen_height / 2)
viewport_1.add_child(player1_camera)

viewport_2 = SubViewport.new()
viewport_2.size = Vector2i(screen_width, screen_height / 2)
viewport_2.add_child(player2_camera)

# Display viewports in split layout
top_half.texture = viewport_1.get_texture()
bottom_half.texture = viewport_2.get_texture()
```

### Checkpoint Sequence Validation

**Pattern:** Track must have ordered checkpoints, validate player passes them in sequence
```gdscript
# CheckpointSystem
var player_last_checkpoint: Dictionary = {}  # player_id -> checkpoint_id

func on_checkpoint_entered(player_id: int, checkpoint_id: int):
    var last = player_last_checkpoint.get(player_id, -1)
    var expected = (last + 1) % checkpoint_count
    
    if checkpoint_id == expected:
        player_last_checkpoint[player_id] = checkpoint_id
        if checkpoint_id == 0:  # Finish line
            RaceManager.complete_lap(player_id)
```

## Sources

- Godot 4.x SubViewport documentation (splitscreen rendering)
- CharacterBody3D best practices for arcade movement
- Open-source Godot kart racing projects (architecture patterns)
- Mario Kart game design deconstructions
- Existing codebase architecture audit (.planning/codebase/ARCHITECTURE.md)

---
*Architecture research for: Arcade Kart Racing*
*Researched: 2026-03-20*
