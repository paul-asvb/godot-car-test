# Requirements: Mario Kart-Style Racing Game

**Defined:** 2026-03-20
**Core Value:** Splitscreen multiplayer is fun and engaging - friends can pick up controllers and race immediately with satisfying arcade physics and competitive gameplay.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Arcade Physics (PHYS)

- [ ] **PHYS-01**: Kart uses CharacterBody3D with arcade movement (not RigidBody3D physics)
- [ ] **PHYS-02**: Snappy, responsive steering with tight control
- [ ] **PHYS-03**: Fast acceleration and high top speed (Mario Kart 8 style)
- [ ] **PHYS-04**: Ground-hugging behavior (kart aligns to track surface normal)
- [ ] **PHYS-05**: Kart maintains speed through turns without excessive slowdown

### Drift System (DRIFT)

- [ ] **DRIFT-01**: Player can enter drift state by holding brake + steering
- [ ] **DRIFT-02**: Kart slides laterally while maintaining forward momentum during drift
- [ ] **DRIFT-03**: Drift has three boost tiers based on duration (blue/orange/pink)
- [ ] **DRIFT-04**: Tier 1 (blue) reached after ~0.5s of drifting
- [ ] **DRIFT-05**: Tier 2 (orange) reached after ~1.5s of drifting
- [ ] **DRIFT-06**: Tier 3 (pink) reached after ~3.0s of drifting
- [ ] **DRIFT-07**: Releasing brake exits drift and applies speed boost based on tier reached
- [ ] **DRIFT-08**: Boost provides temporary speed increase (tier 1: 10%, tier 2: 20%, tier 3: 35%)

### Visual Feedback (VFX)

- [ ] **VFX-01**: Drift sparks emit from kart wheels during drift
- [ ] **VFX-02**: Spark color matches boost tier (blue → orange → pink)
- [ ] **VFX-03**: Boost flame effects trail behind kart during speed boost
- [ ] **VFX-04**: Speed lines or motion blur effect during high speeds
- [ ] **VFX-05**: Camera follows kart smoothly with lerp/damping (no snapping)
- [ ] **VFX-06**: Camera has slight offset during drifts for better visibility

### Track & Environment (TRACK)

- [ ] **TRACK-01**: At least one complete looping race track
- [ ] **TRACK-02**: Track features varied turn types (hairpins, chicanes, wide sweepers)
- [ ] **TRACK-03**: Track includes 8-12 checkpoints for lap validation
- [ ] **TRACK-04**: Checkpoints validate progression sequence (prevent shortcuts)
- [ ] **TRACK-05**: Track has clear visual boundaries (walls, barriers, or off-track zones)
- [ ] **TRACK-06**: Start/finish line clearly marked
- [ ] **TRACK-07**: Track optimized for web build performance (<10k triangles)

### Lap System (LAP)

- [ ] **LAP-01**: Race consists of 3 laps
- [ ] **LAP-02**: Lap counter increments only after passing all checkpoints in sequence
- [ ] **LAP-03**: Finish line detection triggers race completion after lap 3
- [ ] **LAP-04**: Race timer tracks total race time from start to finish
- [ ] **LAP-05**: Individual lap times recorded for each lap
- [ ] **LAP-06**: Player position calculated based on lap + checkpoint progress

### Race UI (UI)

- [ ] **UI-01**: HUD displays current lap (e.g., "Lap 2/3")
- [ ] **UI-02**: HUD displays race timer (MM:SS.MS format)
- [ ] **UI-03**: HUD displays current position (1st, 2nd, 3rd, 4th)
- [ ] **UI-04**: HUD displays current item held (if power-ups implemented)
- [ ] **UI-05**: Starting countdown displays visually (3-2-1-GO)
- [ ] **UI-06**: Starting countdown blocks input until "GO"
- [ ] **UI-07**: Results screen shows final positions and race times
- [ ] **UI-08**: Results screen offers restart/return to menu options

### Splitscreen (SPLIT)

- [ ] **SPLIT-01**: Game supports 2-player local splitscreen
- [ ] **SPLIT-02**: Each player has independent SubViewport rendering
- [ ] **SPLIT-03**: Viewports arranged horizontally or vertically
- [ ] **SPLIT-04**: Per-player input routing (Player 1 = device 0, Player 2 = device 1)
- [ ] **SPLIT-05**: Keyboard and gamepad inputs supported simultaneously
- [ ] **SPLIT-06**: Each player has their own HUD overlay
- [ ] **SPLIT-07**: Splitscreen maintains 30 FPS minimum in web build
- [ ] **SPLIT-08**: Game supports 3-4 player local splitscreen
- [ ] **SPLIT-09**: 4-player mode uses quad-split viewport layout

### Audio (AUDIO)

- [ ] **AUDIO-01**: Engine sound plays continuously, pitch varies with speed
- [ ] **AUDIO-02**: Drift sound effect plays during drift state
- [ ] **AUDIO-03**: Boost activation sound plays when boost applied
- [ ] **AUDIO-04**: Countdown sounds play during starting sequence (3, 2, 1, GO)
- [ ] **AUDIO-05**: Audio streams compressed (OGG format) for web build size

### Power-ups (ITEM)

- [ ] **ITEM-01**: Item boxes placed on track at strategic locations
- [ ] **ITEM-02**: Player picks up item by driving through item box
- [ ] **ITEM-03**: Item box respawns after pickup with delay
- [ ] **ITEM-04**: At least 3 different item types available
- [ ] **ITEM-05**: Speed boost item temporarily increases kart speed
- [ ] **ITEM-06**: Projectile item can be thrown forward to hit opponents
- [ ] **ITEM-07**: Defensive item protects from incoming projectiles
- [ ] **ITEM-08**: Player activates held item with button press
- [ ] **ITEM-09**: Item usage has visual effects (particles, model spawn)
- [ ] **ITEM-10**: Projectiles detect collision with other karts

### Menu System (MENU)

- [ ] **MENU-01**: Main menu allows track selection
- [ ] **MENU-02**: Main menu allows player count selection (1-4)
- [ ] **MENU-03**: Race starts after player count and track selected
- [ ] **MENU-04**: ESC key returns to menu from race
- [ ] **MENU-05**: Results screen offers "Race Again" and "Main Menu" options

### Additional Tracks (TRACK2)

- [ ] **TRACK2-01**: Second race track with different layout
- [ ] **TRACK2-02**: Third race track with different layout
- [ ] **TRACK2-03**: Track selection UI shows all available tracks

### Polish (POLISH)

- [ ] **POLISH-01**: Tire mark trails render behind kart during drift
- [ ] **POLISH-02**: Camera FOV increases slightly during high speed
- [ ] **POLISH-03**: Background music plays during races
- [ ] **POLISH-04**: Web build loads in under 30 seconds
- [ ] **POLISH-05**: Web build size under 50MB

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### AI Opponents
- **AI-01**: Computer-controlled karts race alongside players
- **AI-02**: AI follows racing line through track
- **AI-03**: AI uses items strategically

### Online Multiplayer
- **NET-01**: Network synchronization for remote players
- **NET-02**: Lobby system for matchmaking
- **NET-03**: Latency compensation for smooth online play

### Extended Content
- **CONTENT-01**: 5+ additional race tracks
- **CONTENT-02**: 7+ power-up item types
- **CONTENT-03**: Kart customization (visual variations)
- **CONTENT-04**: Time trial mode with ghost replay

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| AI opponents in v1 | Complex pathfinding, focus on multiplayer first |
| Online multiplayer | Networking complexity, local-only for v1 |
| Track editor | UI complexity, curated tracks ensure quality |
| Character/kart customization | Asset burden, single kart model keeps scope focused |
| Mobile controls | Desktop/web with gamepad focus |
| Story/campaign mode | Party game, not single-player narrative |
| Anti-gravity/underwater sections | Scope increase, focus on ground racing |
| Extensive item variety (10+) | Balance complexity, start with 3-4 core items |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| PHYS-01 through PHYS-05 | Phase 1 | Pending |
| DRIFT-01 through DRIFT-08 | Phase 2 | Pending |
| VFX-01 through VFX-06 | Phase 3 | Pending |
| TRACK-01 through TRACK-07 | Phase 4 | Pending |
| LAP-01 through LAP-06 | Phase 5 | Pending |
| UI-01 through UI-08 | Phase 6 | Pending |
| AUDIO-01 through AUDIO-05 | Phase 7 | Pending |
| SPLIT-01 through SPLIT-07 | Phase 8 | Pending |
| SPLIT-08 through SPLIT-09 | Phase 10 | Pending |
| ITEM-01 through ITEM-10 | Phase 9 | Pending |
| MENU-01 through MENU-05 | Phase 12 | Pending |
| TRACK2-01 through TRACK2-03 | Phase 11 | Pending |
| POLISH-01 through POLISH-05 | Phase 12 | Pending |

**Coverage:**
- v1 requirements: 71 total
- Mapped to phases: 71
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-20*
*Last updated: 2026-03-20 after initial definition*
