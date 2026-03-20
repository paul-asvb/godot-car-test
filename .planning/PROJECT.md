# Mario Kart-Style Racing Game

## What This Is

A web-based arcade kart racer with Mario Kart-style physics and gameplay. Players race on custom tracks with drift mechanics, multi-tier boost system, power-ups, and local splitscreen multiplayer. Built with Godot 4.5 and deployed to the web for easy access.

## Core Value

Splitscreen multiplayer is fun and engaging - friends can pick up controllers and race immediately with satisfying arcade physics and competitive gameplay.

## Requirements

### Validated

- ✓ Godot 4.5 project with web export to GitHub Pages — existing
- ✓ Basic 3D environment and car entity — existing
- ✓ Menu system for scene navigation — existing

### Active

#### Arcade Physics
- [ ] Replace realistic physics with arcade kart handling (CharacterBody3D-based)
- [ ] Snappy, responsive steering with tight control
- [ ] Fast acceleration and high top speed (Mario Kart 8 style)
- [ ] Drift mechanic triggered by brake + turn input
- [ ] Multi-tier drift boost system (blue → orange → pink sparks)
- [ ] Boost speed increase on drift release based on tier
- [ ] Ground-hugging behavior (no realistic suspension simulation)

#### Visual Feedback
- [ ] Drift spark particles (color-coded by boost tier)
- [ ] Boost flame effects during speed boost
- [ ] Speed lines or motion blur during high speed
- [ ] Tire marks/skid trails during drifting
- [ ] Smooth camera follow with slight drift offset

#### Race Track Design
- [ ] Replace obstacle course with looping race track optimized for drifting
- [ ] Track includes checkpoints for lap validation
- [ ] Track features varied turns (hairpins, chicanes, wide sweepers)
- [ ] Visual track boundaries (walls, barriers, off-track areas)
- [ ] At least 2-3 complete race tracks

#### Racing Features
- [ ] Lap counting system (3 laps per race)
- [ ] Race timer and lap time tracking
- [ ] Race UI (current lap, position, lap times)
- [ ] Finish line detection and race completion
- [ ] Starting countdown (3-2-1-GO)

#### Power-Ups
- [ ] Item boxes placed on track
- [ ] Pickup detection and item assignment
- [ ] At least 3-4 different power-up types (speed boost, projectile, defensive, etc.)
- [ ] Item usage input (button press to activate)
- [ ] Visual effects for item usage
- [ ] Item interactions between players

#### Local Splitscreen Multiplayer
- [ ] 2-4 player local multiplayer support
- [ ] Splitscreen viewport rendering (horizontal or vertical split)
- [ ] Per-player input handling (gamepad + keyboard support)
- [ ] Per-player HUD (lap count, position, items)
- [ ] Player position tracking (1st, 2nd, 3rd, 4th)
- [ ] Results screen showing final positions and times

#### Polish
- [ ] Menu with track selection
- [ ] Player count selection (1-4 players)
- [ ] Results screen with replay option
- [ ] Audio (engine sounds, drift sounds, item effects, background music)
- [ ] Smooth performance in web build with 4 players

### Out of Scope

- AI opponents — Focus on multiplayer experience, not single-player vs bots
- Online multiplayer — Local splitscreen only, no networking
- Track editor — Pre-built tracks only
- Character/kart customization — Single kart model
- Advanced items system — Keep power-ups simple (3-4 types max)
- Mobile controls — Desktop/web with gamepad focus
- Extensive single-player campaign — Multiplayer-first design

## Context

**Starting Point:**
This project began as a Godot 4.5 physics demo with a custom raycast-based suspension system. The car drives around an obstacle course with ramps and moving obstacles. The current physics are realistic but not arcade-focused.

**Technical Foundation:**
- Godot 4.5 with Forward Plus renderer
- GDScript for game logic
- Web export via GitHub Actions to GitHub Pages
- Existing menu system and scene management

**Design Direction:**
Shifting from realistic physics simulation to arcade racing gameplay inspired by Mario Kart. The focus is on feel over realism - tight controls, satisfying drifting with boost rewards, and fast-paced multiplayer racing.

**Target Audience:**
Friends playing together locally - the game should be immediately fun and accessible with controllers, no steep learning curve.

## Constraints

- **Platform**: Web (WebAssembly via Godot web export) — Must perform well in browser
- **Tech Stack**: Godot 4.5 + GDScript — No engine change, leverage existing project
- **Multiplayer**: Local splitscreen only (2-4 players) — No networking infrastructure
- **Performance**: Must run smoothly with 4 players in web build — Optimize for WebGL
- **Input**: Keyboard + gamepad support — Web gamepad API constraints
- **Scope**: Focused feature set — Prioritize core racing mechanics over breadth

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Replace RigidBody3D physics with arcade system | Mario Kart feel requires non-realistic, responsive handling | — Pending |
| Brake + turn to initiate drift | Intuitive control scheme, different from dedicated drift button | — Pending |
| Multi-tier drift boost (blue/orange/pink) | Core Mario Kart mechanic that rewards skill | — Pending |
| Local splitscreen over online multiplayer | Much simpler to implement, fits project scope, enables couch co-op | — Pending |
| Web deployment priority | Keep accessibility, easy to share and play | — Pending |
| 2-3 race tracks in v1 | Enough variety without overwhelming scope | — Pending |

---
*Last updated: 2026-03-20 after initialization*
