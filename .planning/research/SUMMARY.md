# Research Summary

**Domain:** Arcade Kart Racing (Mario Kart-style)
**Research Date:** 2026-03-20

## Quick Reference

**Core Decision:** Replace physics-based RigidBody3D system with arcade CharacterBody3D controller
**Key Challenge:** Splitscreen performance in web build (4 viewports = 4x render cost)
**Critical Path:** Drift feel must be perfected early - hardest to tune, affects all gameplay

## Stack Highlights

**Keep from existing:**
- Godot 4.5 engine (excellent for arcade games)
- GDScript (optimal for game logic)
- Web export to GitHub Pages (accessibility)
- Procedural meshes (keep file size low)

**Replace:**
- RigidBody3D → CharacterBody3D (arcade control)
- Raycast suspension → Ground-hugging movement (Mario Kart style)

**Add new:**
- SubViewport for splitscreen (2-4 players)
- GPUParticles3D for drift sparks + boost effects
- MultiMeshInstance3D for tire mark trails

## Feature Priorities

### Must Have (P1 - v1.0 Launch)
1. Arcade kart physics with tight, responsive controls
2. Drift mechanic (brake + turn to enter, hold through corner)
3. Multi-tier boost system (3 tiers: blue/orange/pink sparks)
4. Visual feedback (drift sparks, boost flames, speed lines)
5. Single race track (well-designed for drifting)
6. Lap system (3 laps, checkpoint-based validation)
7. Race UI (lap count, timer, position)
8. 2-player splitscreen (horizontal/vertical split)
9. Basic audio (engine, drift, boost sounds)
10. Starting countdown (3-2-1-GO)
11. Results screen (final positions + times)

### Should Have (P2 - v1.x After Validation)
- 4-player splitscreen (once 2-player is smooth)
- Power-up items (3-4 core types: speed, projectile, defense, trap)
- Multiple tracks (2-3 total)
- Tire mark trails (visual polish)
- Advanced camera (drift offset, dynamic FOV)

### Nice to Have (P3 - Future)
- AI opponents (only if demand for single-player)
- Online multiplayer (major scope increase)
- More tracks (5+)
- Extensive items system (7+ types)

## Architecture Key Points

**Singleton Pattern:**
- RaceManager (autoload) - race state, lap tracking, position calculation
- PowerupManager (autoload) - item state management

**Component Composition:**
- Karts are CharacterBody3D with composed sub-components (controller, visuals, effects, audio)

**Signal-Based Communication:**
- Loose coupling between systems (KartController → EffectsManager via signals)

**Splitscreen via SubViewports:**
- One SubViewport per player, each renders full scene
- Performance critical: lower resolution per viewport, reduce particle counts

## Critical Pitfalls to Avoid

### 1. Drift Feel Tuning Hell
**Problem:** Can spend weeks tweaking constants without finding right feel
**Prevention:** Start with reference values, implement visual feedback FIRST, get external playtesters early
**Phase:** Phase 1 (must nail this before moving forward)

### 2. Splitscreen Performance Collapse
**Problem:** 60 FPS with 2 players, 15 FPS with 4 players - unplayable
**Prevention:** Profile with 4 players FROM DAY ONE, design track for performance, reduce viewport resolution
**Phase:** Phase 4 (performance testing is part of implementation, not afterthought)

### 3. Checkpoint Shortcut Exploits
**Problem:** Players skip track sections, lap counter breaks
**Prevention:** Place checkpoints every major turn (8-12 per lap), validate sequence, playtest for shortcuts
**Phase:** Phase 3 (checkpoint placement and validation must be robust)

### 4. Input Conflicts in Splitscreen
**Problem:** Player 2's input affects Player 1's kart
**Prevention:** Route input by player_id, don't use global input actions, test keyboard + gamepad simultaneously
**Phase:** Phase 4 (input routing architecture critical from start)

### 5. Camera Motion Sickness
**Problem:** Players feel nauseous after 5 minutes
**Prevention:** Lerp camera position/rotation, limit FOV changes, add slight drift lag
**Phase:** Phase 2 (camera smoothing with basic movement)

## Implementation Phases (Suggested)

Based on dependencies and risk mitigation:

**Phase 1:** Core Arcade Physics + Drift System
- Replace RigidBody3D with CharacterBody3D
- Implement arcade movement (acceleration, steering, ground-hugging)
- Drift state machine (normal → drift → boost)
- Multi-tier boost timing (blue/orange/pink)
- **Critical:** Playtest drift feel extensively before proceeding

**Phase 2:** Visual & Audio Feedback
- Drift spark particles (color-coded by tier)
- Boost flame effects
- Speed lines / motion blur
- Camera smoothing and follow
- Engine sound with pitch variation
- Drift and boost sound effects

**Phase 3:** Track + Lap System
- Design first race track (looping, varied turns)
- Checkpoint system (8-12 per lap)
- Lap counting with sequence validation
- Finish line detection
- Race state machine (countdown → racing → finished)

**Phase 4:** Race UI + Splitscreen (2 players)
- Race HUD (lap count, timer, position)
- SubViewport setup for 2 players
- Per-player input routing
- Per-player HUD display
- Starting countdown (3-2-1-GO)
- Results screen
- **Critical:** Performance profiling with 2 viewports

**Phase 5:** Splitscreen Expansion (4 players)
- Extend to 3-4 player support
- Performance optimization (reduce quality if needed)
- Additional input device management

**Phase 6:** Power-up System
- Item boxes on track
- Pickup detection
- 3-4 core item types (speed boost, projectile, defense, trap)
- Item usage mechanics
- Visual effects for items

**Phase 7:** Additional Tracks
- Second track design
- Third track design
- Track selection menu

**Phase 8:** Polish
- Tire mark trails (MultiMeshInstance3D)
- Advanced camera (drift offset, FOV changes)
- Background music
- Positional 3D audio
- Menu improvements
- Web build optimization

## Performance Budget (Web Build)

**Target:**
- 60 FPS with 1-2 players
- 30 FPS minimum with 4 players
- Build size < 50MB
- Load time < 30 seconds

**Optimization Strategies:**
- SubViewport resolution: 720p per player (not 1080p)
- Particle count: max 50-100 per emitter
- Track geometry: < 10k triangles
- Audio: OGG Vorbis compression
- Textures: 1024x1024 max resolution
- Materials: SimpleMaterial3D where possible

## Confidence Levels

| Area | Confidence | Notes |
|------|------------|-------|
| Tech stack choices | HIGH | Godot 4.5 proven for arcade racers, CharacterBody3D is correct choice |
| Feature priorities | HIGH | Research + user goal alignment clear (fun with friends) |
| Architecture patterns | HIGH | Autoload singletons + signal communication standard for Godot |
| Splitscreen performance | MEDIUM | Web build constraint requires careful optimization |
| Drift feel tuning | MEDIUM | Requires iteration, but starting points known |
| Item balance | LOW | Balance is iterative, but scope control mitigates risk |

## Research Gaps

**Not researched (out of scope):**
- AI opponent pathfinding (deferred to v2+)
- Online networking (explicitly out of scope)
- Track editor implementation (out of scope)
- Advanced physics (anti-gravity, underwater) (out of scope)

**Known unknowns:**
- Exact performance with 4 viewports in web (must profile early)
- Drift feel constants (require playtesting iteration)
- Item balance (require multiplayer playtesting)

## Next Steps

1. **Define requirements** from research findings (move to requirements phase)
2. **Create roadmap** with 8-12 focused phases (fine granularity as requested)
3. **Start with Phase 1** (Arcade Physics + Drift) - this is highest risk, must validate feel early

---
*Research summary compiled: 2026-03-20*
*Ready for requirements definition and roadmap creation*
