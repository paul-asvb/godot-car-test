# Phase 2: Drift & Boost System - Context

**Gathered:** 2026-03-22
**Status:** Ready for planning
**Reference Model:** Mario Kart 8 drift mechanics

<domain>
## Phase Boundary

Implement drift mechanic with three-tier boost system (blue/orange/pink sparks). Kart enters drift via brake+steering, slides laterally while maintaining forward momentum, and rewards held drifts with speed boosts upon exit. Must feel responsive to enter, controllable during drift, and rewarding on exit.

</domain>

<decisions>
## Implementation Decisions

### Drift Entry (MK8 Style)

**Trigger:**
- Brake + steering input while grounded at sufficient speed
- Minimum speed threshold: 15 u/s (can't drift while slow/reversing)
- Instant entry: no delay, immediate response on input
- Direction locked on entry: drift direction set by initial steering input

**Entry conditions:**
- Must be grounded (`is_grounded == true`)
- Must be above minimum speed
- Both brake (ui_down) + turn (ui_left/right) held simultaneously
- Cannot enter drift while already boosting

### Drift Physics (MK8 Style)

**Lateral slide:**
- Wide arc trajectory: kart slides outward from turn center
- Steering during drift: limited adjustment (±30% of normal turn rate)
- Slide angle: 20-30 degrees from forward direction
- Forward momentum: maintained at 90-95% of entry speed (slight scrub feel)

**Speed during drift:**
- Entry speed preserved (with 5-10% reduction for slide friction feel)
- No acceleration/deceleration while drifting (coast at drift speed)
- Speed floor: won't drop below 80% of entry speed during long drifts

**Steering control:**
- Can adjust drift angle slightly (wide vs tight line)
- Turn input modifies drift trajectory (±30% range)
- Cannot cancel drift direction (started left = stays left)
- More control than locked, less than normal steering

### Boost Tier System (MK8 Timings)

**Three tiers with timing thresholds:**
- **Tier 1 (Blue)**: 0.5 seconds of continuous drift
- **Tier 2 (Orange)**: 1.5 seconds of continuous drift
- **Tier 3 (Pink)**: 3.0 seconds of continuous drift

**Progression:**
- Linear progression: blue → orange → pink (no skipping)
- Timer starts on drift entry, accumulates while drifting
- Cannot regress: once reached tier 2, won't drop back to tier 1

**Tier retention:**
- Progress preserved during drift (hitting wall doesn't reset)
- Lost on drift exit or speed drop below threshold
- Lost if become airborne (jump during drift cancels it)

**Visual feedback timing:**
- Tier reached = color change (no pre-warning)
- Color persists until drift exits
- Phase 3 will add particle colors

### Drift Exit (MK8 Style)

**Exit trigger:**
- Release brake button (ui_down) while drifting
- Instant exit: immediate transition back to normal state
- Boost applied: based on highest tier reached

**Exit behavior:**
- Smooth orientation snap: kart rotates back to forward-facing over ~0.2s
- Boost surge: speed increase applied instantly
- Can exit early: releasing brake at any time exits (but only get current tier boost)

**Cancel conditions:**
- Become airborne: drift cancelled, no boost awarded
- Speed drops too low (< 10 u/s): drift cancelled, no boost
- Hit wall hard (sudden velocity loss): drift cancelled, boost awarded if tier reached

### Boost Application (MK8 Style)

**Boost multipliers (DRIFT-08):**
- Tier 1 (blue): +10% speed boost
- Tier 2 (orange): +20% speed boost  
- Tier 3 (pink): +35% speed boost

**Boost behavior:**
- Applied on drift exit as additive speed increase
- Instant surge: full boost applied immediately
- Duration: 1.5 seconds of boosted speed
- Smooth falloff: boost decays linearly over duration back to normal speed

**Boost stacking:**
- Cannot enter new drift while boosting
- Cannot stack boosts (no double-boost)
- Can chain: boost → normal → drift → boost (sequential chaining)

**Speed cap:**
- Boost can exceed MAX_SPEED temporarily
- No upper limit during boost (tier 3 at max speed = 35 * 1.35 = 47.25 u/s)
- Reverts to MAX_SPEED cap after boost ends

### State Machine

**Three states:**
1. **Normal**: Standard arcade movement (Phase 1 behavior)
2. **Drifting**: Drift physics active, tier timer running
3. **Boosting**: Speed boost active, boost timer counting down

**Transitions:**
- Normal → Drifting: brake + turn input (conditions met)
- Drifting → Boosting: release brake (awards boost)
- Drifting → Normal: cancel condition (no boost)
- Boosting → Normal: boost timer expires
- Boosting → Drifting: blocked (must finish boost first)

### Claude's Discretion

**Tuning constants to define:**
- Drift slide angle (20-30 degrees recommended)
- Drift speed retention percentage (90-95%)
- Drift steering adjustment range (±30% of normal)
- Boost decay curve shape (linear vs ease-out)
- Entry speed threshold (15 u/s recommended)
- Exit orientation snap speed (~0.2s recommended)

**Technical implementation:**
- State enum or string-based state tracking
- Timer implementation (delta accumulation vs Time.get_ticks_msec)
- Drift direction vector calculation
- Boost speed modification method

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase 1 Implementation
- `entities/car/arcade_car.gd` — CharacterBody3D foundation, state variables, movement methods
- `.planning/phases/01-core-arcade-physics/01-CONTEXT.md` — Movement decisions
- `.planning/phases/01-core-arcade-physics/PHASE-COMPLETE.md` — Integration points

### Project Requirements
- `.planning/REQUIREMENTS.md` — DRIFT-01 through DRIFT-08 define acceptance criteria
- `.planning/PROJECT.md` — Design direction emphasizes "feel over realism"

### Reference Material
- Mario Kart 8 drift mechanics: instant entry, three-tier boost, wide-arc slide

</canonical_refs>

<code_context>
## Existing Code Integration

### Reusable from Phase 1

**State variables (arcade_car.gd lines 51-56):**
- `current_speed` → modify during drift (reduce slightly) and boost (multiply)
- `current_turn` → modify during drift (reduce turn rate)
- `is_grounded` → gate drift entry (must be true)
- `ground_normal` → could influence drift angle on slopes

**Methods to extend:**
- `_handle_steering(delta, steer_input)` → add drift state check, modify turn rate
- `_handle_acceleration(delta, throttle, brake)` → add boost speed application
- `_physics_process(delta)` → add state machine logic

**Patterns to reuse:**
- Smooth interpolation: `move_toward()` for boost decay
- State flags: add `is_drifting`, `is_boosting` booleans
- Timer tracking: delta accumulation for drift duration
- Input detection: brake + turn combination check

### New Components Needed

**State tracking:**
- Current state enum/string (normal/drifting/boosting)
- Drift timer (float, accumulates during drift)
- Current tier (int, 0-3)
- Boost timer (float, counts down during boost)
- Drift direction (Vector3 or float, set on entry)

**Methods to add:**
- `_enter_drift(direction)` → initialize drift state
- `_exit_drift()` → apply boost, return to normal
- `_update_drift(delta)` → handle drift physics and tier progression
- `_update_boost(delta)` → handle boost decay
- `_check_drift_entry()` → validate conditions and trigger

**Constants to define:**
```gdscript
@export_group("Drift")
@export var DRIFT_MIN_SPEED = 15.0
@export var DRIFT_TURN_RATE_MULT = 0.3
@export var DRIFT_SPEED_RETENTION = 0.95
@export var DRIFT_SLIDE_ANGLE = 25.0  # degrees

@export_group("Boost Tiers")
@export var TIER1_TIME = 0.5
@export var TIER2_TIME = 1.5
@export var TIER3_TIME = 3.0
@export var TIER1_BOOST = 1.10  # 10%
@export var TIER2_BOOST = 1.20  # 20%
@export var TIER3_BOOST = 1.35  # 35%
@export var BOOST_DURATION = 1.5
```

### Integration Points

**Input handling:**
- Brake detection: `Input.is_action_pressed("ui_down")`
- Turn detection: `Input.is_action_pressed("ui_left/right")`
- Combination check: both active = drift trigger

**Speed modifications:**
- During drift: `current_speed *= DRIFT_SPEED_RETENTION`
- During boost: `effective_speed = current_speed * boost_multiplier`
- Boost decay: `boost_mult = lerp(boost_mult, 1.0, delta / BOOST_DURATION)`

**Steering modifications:**
- During drift: `effective_turn_rate = MAX_TURN_RATE * DRIFT_TURN_RATE_MULT`
- During normal/boost: use full `MAX_TURN_RATE`

**Visual readiness (for Phase 3):**
- Current tier exposed as variable (for spark color)
- Drift state exposed (for particle activation)
- Boost state exposed (for flame effects)

</code_context>

<specifics>
## Specific Ideas

**MK8 reference points:**
- Instant drift entry (no wind-up delay)
- Wide, sweeping arcs (not tight hairpin drifts)
- Three-tier system with clear timing breakpoints
- Significant tier 3 reward (35% boost encourages long drifts)
- Drift chaining is core skill (boost → drift → boost loop)

**Feel priorities:**
- Drift entry must feel instant and responsive
- Slide should feel controllable but different from normal steering
- Tier progression should be noticeable (even without visual feedback yet)
- Boost must feel rewarding (significant speed surge)

**Balance notes:**
- Tier 3 requires 3 seconds (longer than most corners) - encourages chaining
- Tier 1 at 0.5s provides quick reward for short drifts
- Speed retention (95%) prevents drift from feeling slow
- Boost duration (1.5s) long enough to feel impact, short enough to require chaining

</specifics>

<deferred>
## Deferred Ideas

**Not in Phase 2 scope:**
- Visual spark effects (blue/orange/pink particles) → Phase 3: Visual Feedback
- Boost flame trails → Phase 3: Visual Feedback
- Camera offset during drift → Phase 3: Visual Feedback
- Tire mark trails → Phase 12: Polish
- Drift sounds/audio → Phase 7: Basic Audio
- Mini-turbo start boosts → Future consideration
- Purple sparks (ultra mini-turbo) → v2 feature
- Drift hopping (MK Wii style) → Not matching MK8 reference

**Noted for future phases:**
- VFX-01/02: Spark color tied to tier (Phase 3 will read tier variable)
- AUDIO-02: Drift sound effect (Phase 7 will read is_drifting flag)

</deferred>

---

*Phase: 02-drift-boost-system*
*Context gathered: 2026-03-22 (Auto-mode: MK8 defaults)*
*Reference: Mario Kart 8 drift mechanics*
