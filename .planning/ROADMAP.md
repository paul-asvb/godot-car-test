# Roadmap: Mario Kart-Style Racing Game

**Created:** 2026-03-20
**Granularity:** Fine (8-12 focused phases)
**Strategy:** Build core gameplay loop first, then expand multiplayer and content

## Phase Overview

| # | Phase | Requirements | Est. Plans | Status |
|---|-------|--------------|------------|--------|
| 1 | Core Arcade Physics | PHYS-01 to PHYS-05 | 3-5 | Pending |
| 2 | Drift & Boost System | DRIFT-01 to DRIFT-08 | 4-6 | Pending |
| 3 | Visual Feedback | VFX-01 to VFX-06 | 5-7 | Pending |
| 4 | First Race Track | TRACK-01 to TRACK-07 | 6-8 | Pending |
| 5 | Lap & Race System | LAP-01 to LAP-06 | 4-6 | Pending |
| 6 | Race UI & HUD | UI-01 to UI-08 | 5-7 | Pending |
| 7 | Basic Audio | AUDIO-01 to AUDIO-05 | 3-5 | Pending |
| 8 | 2-Player Splitscreen | SPLIT-01 to SPLIT-07 | 7-9 | Pending |
| 9 | Power-up System | ITEM-01 to ITEM-10 | 8-10 | Pending |
| 10 | 4-Player Splitscreen | SPLIT-08 to SPLIT-09 | 5-7 | Pending |
| 11 | Additional Tracks | TRACK2-01 to TRACK2-03 | 6-8 | Pending |
| 12 | Polish & Optimization | POLISH-01 to POLISH-05, MENU-01 to MENU-05 | 7-9 | Pending |

**Total:** 12 phases | 71 requirements | 63-87 estimated plans

---

## Phase 1: Core Arcade Physics

**Goal:** Replace RigidBody3D physics with CharacterBody3D arcade movement that feels responsive and fun.

**Requirements:**
- PHYS-01: Kart uses CharacterBody3D with arcade movement
- PHYS-02: Snappy, responsive steering with tight control
- PHYS-03: Fast acceleration and high top speed
- PHYS-04: Ground-hugging behavior (kart aligns to track)
- PHYS-05: Kart maintains speed through turns

**Success Criteria:**
1. Kart responds immediately to input (no lag or sluggishness)
2. Steering feels tight - can navigate figure-8 pattern smoothly
3. Kart reaches high speed quickly (full speed in ~2 seconds)
4. Kart stays aligned to ground surface on slopes/ramps
5. Can take turns at high speed without excessive slowdown

**Why This First:**
Research identified drift feel as highest risk. Must nail basic movement before adding drift complexity. Everything builds on this foundation.

**Dependencies:** None (fresh start)

**Estimated Plans:** 3-5
- Replace car.gd RigidBody3D with CharacterBody3D
- Implement arcade acceleration/deceleration
- Implement responsive steering with turn rate limits
- Ground-hugging with surface normal alignment
- Tune speed/handling constants for arcade feel

---

## Phase 2: Drift & Boost System

**Goal:** Implement drift mechanic with multi-tier boost rewards (blue/orange/pink sparks).

**Requirements:**
- DRIFT-01: Enter drift with brake + steering
- DRIFT-02: Lateral slide while maintaining forward momentum
- DRIFT-03: Three boost tiers based on drift duration
- DRIFT-04: Tier 1 (blue) at ~0.5s
- DRIFT-05: Tier 2 (orange) at ~1.5s
- DRIFT-06: Tier 3 (pink) at ~3.0s
- DRIFT-07: Release brake to exit drift and apply boost
- DRIFT-08: Boost speed increases by tier (10%/20%/35%)

**Success Criteria:**
1. Brake + turn input enters drift state smoothly
2. Kart slides sideways while moving forward during drift
3. Holding drift for 0.5s/1.5s/3.0s triggers tier progression
4. Releasing brake applies speed boost matching tier reached
5. Can chain drifts through multiple corners to maintain speed

**Why This Next:**
Drift system is core gameplay loop. Must be implemented early and tuned extensively. Research warns this takes iteration to feel right.

**Dependencies:** Phase 1 (needs working arcade movement)

**Estimated Plans:** 4-6
- Drift state machine (normal/drifting/boosting states)
- Drift input detection (brake + turn)
- Lateral slide physics during drift
- Boost tier timer system
- Boost speed application on drift exit
- Tune drift feel constants (turn rate, slide friction, boost duration)

---

## Phase 3: Visual Feedback

**Goal:** Add particle effects and camera polish so players can see drift tiers and feel speed.

**Requirements:**
- VFX-01: Drift sparks from wheels
- VFX-02: Spark color matches tier (blue/orange/pink)
- VFX-03: Boost flames during speed boost
- VFX-04: Speed lines during high speed
- VFX-05: Camera smooth following with lerp
- VFX-06: Camera offset during drifts

**Success Criteria:**
1. Sparks emit from wheels during drift, color changes with tiers
2. Boost flames appear behind kart when boost is active
3. Speed lines intensify at high speeds
4. Camera follows kart smoothly without jerky snapping
5. Camera shifts slightly during drifts for better turn visibility

**Why This Next:**
Visual feedback is essential for gameplay clarity. Players need to see what tier they're in. Research emphasizes implementing visual feedback BEFORE tuning physics feel.

**Dependencies:** Phase 2 (needs drift states to trigger effects)

**Estimated Plans:** 5-7
- GPUParticles3D drift sparks with color-changing material
- Boost flame particles
- Speed lines effect (shader or particles)
- Camera controller with lerp/damping
- Camera drift offset logic
- Performance optimization for web (particle count limits)

---

## Phase 4: First Race Track

**Goal:** Design and build one complete race track optimized for drifting with checkpoint system.

**Requirements:**
- TRACK-01: Complete looping race track
- TRACK-02: Varied turn types (hairpins, chicanes, sweepers)
- TRACK-03: 8-12 checkpoints for lap validation
- TRACK-04: Checkpoints validate sequence (prevent shortcuts)
- TRACK-05: Clear visual boundaries (walls/barriers)
- TRACK-06: Start/finish line marked
- TRACK-07: Optimized for web (<10k triangles)

**Success Criteria:**
1. Track loops back to start, takes 1-2 minutes per lap
2. Mix of tight hairpins, technical chicanes, and wide sweepers
3. All major turns have checkpoints, can't skip sections
4. Checkpoints detect cars passing through in correct order
5. Walls/barriers prevent driving off-track

**Why This Next:**
Need a proper track to test kart physics and drift mechanics. Research shows track design significantly impacts gameplay feel.

**Dependencies:** Phase 3 (needs working kart to test track design)

**Estimated Plans:** 6-8
- Track mesh design (procedural or modeling)
- Track surface material (grip zones optional)
- Checkpoint Area3D placement (8-12 locations)
- Checkpoint sequence validation logic
- Boundary walls/collision
- Start/finish line visual markers
- Performance profiling (<10k triangles target)

---

## Phase 5: Lap & Race System

**Goal:** Implement lap counting, race timing, and position tracking for competitive racing.

**Requirements:**
- LAP-01: 3 laps per race
- LAP-02: Lap increments only after all checkpoints in sequence
- LAP-03: Finish line triggers race completion after lap 3
- LAP-04: Race timer tracks total time
- LAP-05: Individual lap times recorded
- LAP-06: Player position calculated (lap + checkpoint progress)

**Success Criteria:**
1. Race starts with lap 1/3, increments correctly each lap
2. Shortcuts don't increment lap counter (checkpoint validation works)
3. Crossing finish on lap 3 completes race
4. Race timer shows MM:SS.MS from start to finish
5. Each lap time recorded, best lap time tracked

**Why This Next:**
Lap system provides structure to races. Position tracking enables competitive multiplayer.

**Dependencies:** Phase 4 (needs checkpoints to validate laps)

**Estimated Plans:** 4-6
- RaceManager singleton for race state
- Lap counter with checkpoint validation
- Race timer (total + per-lap)
- Finish line detection logic
- Position calculation from lap + checkpoint data
- Race completion trigger

---

## Phase 6: Race UI & HUD

**Goal:** Display race information (lap, time, position, countdown) to players.

**Requirements:**
- UI-01: Current lap display (Lap 2/3)
- UI-02: Race timer (MM:SS.MS)
- UI-03: Current position (1st/2nd/3rd/4th)
- UI-04: Item held display (for Phase 9)
- UI-05: Starting countdown visual (3-2-1-GO)
- UI-06: Countdown blocks input until GO
- UI-07: Results screen with final positions/times
- UI-08: Results screen restart/menu options

**Success Criteria:**
1. Lap counter updates each lap, clearly visible
2. Race timer counts up, formatted correctly
3. Position number shows player standing
4. Countdown prevents movement until GO
5. Results screen shows all players' final times and positions

**Why This Next:**
UI makes race state visible. Countdown provides fair race starts.

**Dependencies:** Phase 5 (needs race state to display)

**Estimated Plans:** 5-7
- Race HUD Control node (lap, timer, position)
- Countdown UI and logic
- Race start input blocking
- Results screen scene
- Results screen population from race data
- Restart/menu navigation from results

---

## Phase 7: Basic Audio

**Goal:** Add engine, drift, and boost sounds for auditory feedback.

**Requirements:**
- AUDIO-01: Engine sound with speed-based pitch
- AUDIO-02: Drift sound during drift state
- AUDIO-03: Boost activation sound
- AUDIO-04: Countdown sounds (3, 2, 1, GO)
- AUDIO-05: Audio compressed (OGG format)

**Success Criteria:**
1. Engine sound plays continuously, pitch increases with speed
2. Drift sound plays during drift, stops on drift exit
3. Boost sound plays when boost activates
4. Countdown beeps on 3-2-1, different sound on GO
5. Audio files compressed, total audio <5MB

**Why This Next:**
Audio significantly improves game feel. Relatively quick to implement before tackling splitscreen complexity.

**Dependencies:** Phase 2 (needs drift states for audio triggers)

**Estimated Plans:** 3-5
- AudioStreamPlayer nodes for engine/drift/boost
- Engine pitch modulation based on speed
- Drift/boost audio triggers from state changes
- Countdown audio sequence
- Audio compression and optimization

---

## Phase 8: 2-Player Splitscreen

**Goal:** Enable 2-player local multiplayer with split viewports and per-player input.

**Requirements:**
- SPLIT-01: 2-player local multiplayer support
- SPLIT-02: Independent SubViewport per player
- SPLIT-03: Horizontal or vertical viewport split
- SPLIT-04: Per-player input routing (device 0/1)
- SPLIT-05: Keyboard + gamepad support simultaneously
- SPLIT-06: Per-player HUD overlay
- SPLIT-07: 30 FPS minimum in web build

**Success Criteria:**
1. Two players can race simultaneously on same device
2. Each player sees from their kart's camera
3. Player 1 keyboard, Player 2 gamepad works (or both gamepads)
4. Each player has their own lap/position/timer display
5. Performance: 30+ FPS with 2 players in web build

**Why This Next:**
Research identified splitscreen performance as critical risk. Implement 2-player first to validate performance before 4-player.

**Dependencies:** Phase 6 (needs HUD to duplicate per player)

**Estimated Plans:** 7-9
- SubViewport creation and setup
- Viewport split layout (horizontal/vertical)
- Per-player camera assignment
- Input routing system (device ID mapping)
- Duplicate HUD per viewport
- Performance profiling (viewport resolution, particle limits)
- 2-player race testing and optimization

---

## Phase 9: Power-up System

**Goal:** Add item boxes and 3-4 core power-up types for competitive chaos.

**Requirements:**
- ITEM-01: Item boxes on track
- ITEM-02: Pickup detection by driving through
- ITEM-03: Item box respawn after pickup
- ITEM-04: 3 different item types minimum
- ITEM-05: Speed boost item
- ITEM-06: Projectile item (thrown forward)
- ITEM-07: Defensive item (shield)
- ITEM-08: Item activation via button press
- ITEM-09: Visual effects for item usage
- ITEM-10: Projectile collision with karts

**Success Criteria:**
1. Item boxes placed on track, visible and collectible
2. Driving through box assigns random item to player
3. Box respawns after ~10 seconds
4. At least 3 items: speed boost, projectile, defense
5. Projectiles affect other players (spin out, slowdown)

**Why This Next:**
Power-ups add competitive layer. Implemented after core racing works. Research warns to limit item count (3-4) to control balance complexity.

**Dependencies:** Phase 8 (more fun with multiple players)

**Estimated Plans:** 8-10
- Item box scene and placement on track
- Item pickup detection (Area3D)
- Item box respawn system
- PowerupManager singleton
- Speed boost item implementation
- Projectile item (spawn, movement, collision)
- Defensive item (shield effect)
- Item activation input
- Item visual effects
- Projectile-kart collision handling

---

## Phase 10: 4-Player Splitscreen

**Goal:** Expand splitscreen to 3-4 players with quad-split layout.

**Requirements:**
- SPLIT-08: 3-4 player local multiplayer
- SPLIT-09: Quad-split viewport layout (2x2 grid)

**Success Criteria:**
1. 4 players can race simultaneously
2. Quad-split layout (top-left, top-right, bottom-left, bottom-right)
3. Each player has independent controls and HUD
4. Performance: 30 FPS minimum with 4 players in web build
5. Input routing supports 4 devices (keyboards + gamepads)

**Why This Next:**
Research emphasizes testing 4-player performance early. This validates web build can handle target player count.

**Dependencies:** Phase 9 (4-player more interesting with items)

**Estimated Plans:** 5-7
- Quad-split viewport layout (2x2)
- 3rd and 4th player input routing
- Performance optimization (reduce viewport resolution if needed)
- 4-player race testing
- Dynamic quality scaling based on player count

---

## Phase 11: Additional Tracks

**Goal:** Build 2 more tracks for variety and replayability.

**Requirements:**
- TRACK2-01: Second race track
- TRACK2-02: Third race track
- TRACK2-03: Track selection UI

**Success Criteria:**
1. Track 2 has different layout/theme from Track 1
2. Track 3 offers unique turns and challenges
3. Track selection menu shows all 3 tracks
4. Each track validated with checkpoints
5. All tracks optimized for web performance

**Why This Next:**
Core mechanics complete, now add content variety. 3 tracks provides replayability without overwhelming scope.

**Dependencies:** Phase 10 (validate gameplay with max players first)

**Estimated Plans:** 6-8
- Track 2 design and implementation
- Track 3 design and implementation
- Track data structure (checkpoint positions, metadata)
- Track selection UI scene
- Track loading system
- Per-track checkpoint setup

---

## Phase 12: Polish & Optimization

**Goal:** Final polish, menu improvements, and web build optimization.

**Requirements:**
- POLISH-01: Tire mark trails during drift
- POLISH-02: Camera FOV increases at high speed
- POLISH-03: Background music during races
- POLISH-04: Web build loads in <30 seconds
- POLISH-05: Web build size <50MB
- MENU-01: Main menu track selection
- MENU-02: Player count selection (1-4)
- MENU-03: Race starts after selections
- MENU-04: ESC returns to menu
- MENU-05: Results offers replay/menu options

**Success Criteria:**
1. Tire marks trail behind kart during drift
2. Camera FOV dynamically adjusts with speed
3. Background music plays, loops smoothly
4. Web build loads quickly (<30s on broadband)
5. Web build size optimized (<50MB total)

**Why This Last:**
Polish improves feel but isn't blocking. Menu already functional, just needs refinement. Web optimization done last when content is final.

**Dependencies:** Phase 11 (all features complete)

**Estimated Plans:** 7-9
- Tire mark trails (MultiMeshInstance3D)
- Dynamic camera FOV based on speed
- Background music integration and looping
- Menu polish and flow improvements
- Web build size optimization (audio/texture compression)
- Build load time optimization
- Final performance profiling
- Web deployment testing

---

## Coverage Validation

**v1 Requirements:** 71 total
**Mapped to phases:** 71
**Unmapped:** 0 ✓

**Coverage by category:**
- PHYS (5 reqs) → Phase 1
- DRIFT (8 reqs) → Phase 2
- VFX (6 reqs) → Phase 3
- TRACK (7 reqs) → Phase 4
- LAP (6 reqs) → Phase 5
- UI (8 reqs) → Phase 6
- AUDIO (5 reqs) → Phase 7
- SPLIT (9 reqs) → Phases 8, 10
- ITEM (10 reqs) → Phase 9
- MENU (5 reqs) → Phase 12
- TRACK2 (3 reqs) → Phase 11
- POLISH (5 reqs) → Phase 12

**All v1 requirements covered ✓**

---

## Risk Mitigation

**High Risk Items:**
1. **Drift feel tuning (Phase 2)** - Research warns this is iterative. Plan extensive playtesting time.
2. **Splitscreen performance (Phases 8, 10)** - Profile early with 4 viewports. May need quality reduction.
3. **Checkpoint shortcuts (Phase 4)** - Playtest for exploits. Add barriers if needed.

**Critical Path:**
Phases 1-2 are highest risk and block everything. Must nail arcade feel and drift mechanics before proceeding.

---

*Roadmap created: 2026-03-20*
*Last updated: 2026-03-20 after initialization*
