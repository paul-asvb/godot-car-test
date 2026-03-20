# Structure Analysis

**Analyzed:** 2026-03-20
**Codebase:** Godot 4.5 3D Game

## Directory Layout

```
godot-car-test/
├── .git/                          # Git repository
├── .github/                       # GitHub configuration
│   └── workflows/
│       └── deploy.yml             # GitHub Actions CI/CD
├── .godot/                        # Godot cache (gitignored)
├── .opencode/                     # OpenCode configuration
├── .planning/                     # GSD planning docs
│   └── codebase/                  # This codebase map
├── entities/                      # Game entity scripts + assets
│   ├── car/
│   │   └── car.gd                 # Car physics script (126 lines)
│   └── obstacles/
│       └── moving_obstacle.gd     # Moving obstacle script (16 lines)
├── scenes/                        # Scene files (.tscn)
│   ├── car_only.tscn              # Simplified scene (car only)
│   ├── main.tscn                  # Main gameplay scene (589 lines)
│   └── menu.tscn                  # Menu UI scene (53 lines)
├── AGENTS.md                      # AI agent documentation
├── README.md                      # Project readme
├── .gitignore                     # Git ignore rules
├── justfile                       # Just task runner config
└── project.godot                  # Godot project configuration
```

## Key Directories

**`entities/`** - Game entity logic
- Purpose: Self-contained entity scripts
- Pattern: One subdirectory per entity type
- Naming: Entity name (singular)
- Contents: GDScript files, optionally related assets

**`scenes/`** - Godot scene files
- Purpose: Composition of nodes into reusable scenes
- Format: `.tscn` (text-based scene format)
- Naming: Descriptive scene name (snake_case)
- Types: UI scenes, gameplay scenes, entity scenes

**`.github/workflows/`** - CI/CD automation
- Purpose: Automated builds and deployment
- Files: `deploy.yml` (GitHub Actions workflow)

**`.planning/`** - GSD project planning
- Purpose: Project management documents
- Created by: GSD workflow tools
- Not part of game code

## Key Files

**Root Level:**

`project.godot` (19 lines)
- Godot project configuration
- Defines main scene, project name, Godot version
- Engine-generated, rarely edited manually

`justfile` (26 lines)
- Task automation (build, run, clean, watch)
- Defines build commands for web export

`README.md` (44 lines)
- Project documentation
- Controls, running instructions, structure overview

`AGENTS.md` (58 lines)
- AI agent collaboration guide
- Project structure, conventions, gotchas

`.gitignore` (11 lines)
- Excludes `.godot/`, export presets, Mono artifacts

**Entity Scripts:**

`entities/car/car.gd` (126 lines)
- Car physics implementation
- Attached to Car (RigidBody3D) node in main.tscn
- Custom suspension via raycasts

`entities/obstacles/moving_obstacle.gd` (16 lines)
- Moving obstacle behavior
- Sinusoidal motion pattern
- Attached to MovingObstacle nodes

**Scenes:**

`scenes/menu.tscn` (53 lines)
- Menu UI scene
- Inline GDScript for button handlers
- Scene selection interface

`scenes/main.tscn` (589 lines)
- Main gameplay scene
- Obstacle course layout
- References car.gd and moving_obstacle.gd

`scenes/car_only.tscn` (not analyzed, inferred)
- Simplified test scene
- Car without obstacles

**CI/CD:**

`.github/workflows/deploy.yml` (92 lines)
- GitHub Actions workflow
- Builds web export, deploys to GitHub Pages
- Uses barichello/godot-ci:4.5 Docker image

## Naming Conventions

**Directories:**
- `snake_case` for all directories
- Plural for collections: `entities/`, `scenes/`
- Singular for specific entities: `entities/car/`

**GDScript Files:**
- `snake_case.gd`
- Entity name matches directory: `car/car.gd`
- Descriptive behavior: `moving_obstacle.gd`

**Scene Files:**
- `snake_case.tscn`
- Descriptive names: `main.tscn`, `menu.tscn`, `car_only.tscn`

**Node Names (in scenes):**
- `PascalCase` for node names: `DirectionalLight3D`, `Car`, `Ground`
- Descriptive suffixes: `WheelFL`, `WheelFR`, `Boulder1`, `Ramp3`

**Constants (in GDScript):**
- `SCREAMING_SNAKE_CASE`: `SPRING_STRENGTH`, `ENGINE_FORCE`, `MAX_STEER_ANGLE`

**Variables/Functions (in GDScript):**
- `snake_case`: `current_steer`, `reset_position()`, `get_point_velocity()`

## File Organization Patterns

**Entity Pattern:**
```
entities/{entity_type}/
  └── {entity_type}.gd
```

Example: `entities/car/car.gd`

**Scene Pattern:**
```
scenes/{scene_name}.tscn
```

Example: `scenes/main.tscn`

**No Asset Subdirectories:**
- No separate textures/, models/, audio/ directories
- All assets generated procedurally in scenes
- If external assets added, typical pattern would be:
  ```
  entities/car/
    ├── car.gd
    ├── car_mesh.glb      (hypothetical)
    └── car_texture.png   (hypothetical)
  ```

## Import Paths

**Godot Resource Paths:**
- Format: `res://path/to/resource`
- Examples:
  - `res://scenes/main.tscn`
  - `res://scenes/menu.tscn`
  - `res://entities/car/car.gd`

**Script Attachment:**
- Scenes reference scripts via `ExtResource` with UID
- Example: `script = ExtResource("1_car")` → `entities/car/car.gd`

**No Explicit Imports:**
- GDScript doesn't use import statements for project files
- Scripts access nodes via scene tree hierarchy

## Configuration Locations

**Project Config:** `project.godot` (root)
- Application settings
- Input mappings (implied, using default arrow keys)
- Rendering settings (Forward Plus)

**Build Config:** `justfile` (root)
- Build commands
- Export paths

**CI Config:** `.github/workflows/deploy.yml`
- GitHub Actions workflow
- Build steps, deployment

**Export Config:** `export_presets.cfg` (generated, gitignored)
- Export platform settings
- Created dynamically in CI

**Git Config:** `.gitignore` (root)
- Ignored files/directories

## Typical File Locations

**Where to find:**
- Scripts: `entities/{type}/{type}.gd`
- Scenes: `scenes/{name}.tscn`
- Project settings: `project.godot`
- Build tasks: `justfile`
- CI: `.github/workflows/`
- Documentation: `README.md`, `AGENTS.md`

**Where NOT to look:**
- No `src/` directory (common in other languages)
- No `assets/` directory (procedural generation)
- No `scripts/` directory (scripts live with entities)
- No `lib/` or `vendor/` (no external dependencies)

## Growth Recommendations

**If project expands:**

1. **Separate Asset Directories:**
   ```
   assets/
     ├── models/
     ├── textures/
     ├── audio/
     └── materials/
   ```

2. **Autoload Scripts (singletons):**
   ```
   autoload/
     ├── game_manager.gd
     ├── audio_manager.gd
     └── settings.gd
   ```

3. **UI Subsystem:**
   ```
   ui/
     ├── menus/
     ├── hud/
     └── components/
   ```

4. **Shared Utilities:**
   ```
   utils/
     ├── math_utils.gd
     └── input_utils.gd
   ```

5. **Test Structure:**
   ```
   tests/
     ├── unit/
     └── integration/
   ```

---
*Structure documented: 2026-03-20*
