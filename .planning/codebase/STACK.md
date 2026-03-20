# Stack Analysis

**Analyzed:** 2026-03-20
**Codebase:** Godot 4.5 3D Game

## Runtime

**Engine:** Godot 4.5+
- Renderer: Forward Plus (modern 3D rendering pipeline)
- Configuration: `project.godot` (config_version=5)
- Main entry: `res://scenes/menu.tscn`

**Language:** GDScript
- Version: Godot 4.x GDScript (non-Mono)
- Type system: Dynamic typing (no explicit type annotations in current code)
- File extension: `.gd`

## Dependencies

**Core Dependencies:**
- Godot Engine 4.5+ (barichello/godot-ci:4.5 in CI)
- No external GDScript libraries
- No third-party plugins

**Build Tools:**
- `just` task runner (`justfile`)
- GitHub Actions (automated deployment)

## Frameworks & Libraries

**Game Framework:**
- Pure Godot 4.5 - no additional frameworks
- Built-in physics engine (RigidBody3D, AnimatableBody3D, StaticBody3D)
- Built-in scene system (.tscn files)

**Physics System:**
- Custom raycast-based suspension (`entities/car/car.gd`)
- Spring-damper model
- Manual tire grip simulation

## Configuration Files

**Project Configuration:**
- `project.godot` - Main engine config
  - Project name: "Godot Car Test"
  - Main scene: `res://scenes/menu.tscn`
  - Features: Godot 4.5, Forward Plus renderer
  - Assembly name: "Godot Car Test" (.NET compatibility marker, but not actually using .NET)

**Build Configuration:**
- `justfile` - Task automation
  - `build-web` - Export to WebAssembly
  - `run` - Launch main scene
  - `watch` - Auto-rebuild on file changes
  - Export directory: `build/web`

**CI/CD:**
- `.github/workflows/deploy.yml` - GitHub Actions workflow
  - Builds web export for GitHub Pages
  - Uses barichello/godot-ci:4.5 Docker image
  - Auto-deploys on push to main branch

**Version Control:**
- `.gitignore` - Excludes `.godot/`, export presets, Mono artifacts

## Development Environment

**Editor:** Godot Editor 4.5+
- Scene editing via Godot UI
- Script editing (GDScript)
- Built-in debugger

**CLI Commands:**
- `godot` - Open project in editor
- `godot scenes/main.tscn` - Run specific scene
- `godot --headless` - Headless mode (CI/testing)
- `godot --headless --export-release "Web" <path>` - Export build

**Task Runner:**
- `just build-web` - Build web version
- `just run` - Run locally
- `just watch` - Watch mode with inotifywait
- `just clean` - Remove build artifacts

## Export Targets

**Web (WebAssembly):**
- Platform: HTML5 via Godot web export
- Output: `build/web/index.html`
- Deployment: GitHub Pages (automated via Actions)
- Template: Godot 4.5 web export templates

## Stack Rationale

**Why Godot 4.5:**
- Modern 3D rendering (Forward Plus)
- Mature physics engine
- Free and open source
- Good WebAssembly support
- Active community

**Why GDScript:**
- Native Godot language
- Tight engine integration
- Good performance for game logic
- Simpler than C# for physics prototypes

**Why Custom Physics:**
- Demonstrates low-level control
- Educational/experimental purpose
- More flexible than VehicleBody3D
- Allows fine-tuning suspension behavior

## Version Notes

**Godot 4.5:**
- Latest stable as of codebase analysis
- Breaking changes from Godot 3.x (not backward compatible)
- Scene format version: 3 (uid-based references)

**GDScript Compatibility:**
- Godot 4.x syntax (extends keyword, @export, @onready)
- Not compatible with Godot 3.x GDScript

---
*Stack documented: 2026-03-20*
