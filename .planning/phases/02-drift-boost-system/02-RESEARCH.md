# Phase 2: Drift & Boost System - Research

**Created:** 2026-03-22
**Phase:** 02-drift-boost-system
**Focus:** State machine implementation, drift physics, boost timing, and tier progression

## Summary

Research into implementing MK8-style drift mechanics on top of Phase 1's CharacterBody3D foundation. Key findings: Enum-based state machine provides clean transitions, drift slide requires velocity composition (forward + lateral), boost decay uses lerp for smooth falloff, and tier progression needs threshold-based timer checks with no regression logic.

## Domain Knowledge

### State Machine Patterns

**GDScript state management approaches:**

**Option A: Enum-based (RECOMMENDED)**
```gdscript
enum State { NORMAL, DRIFTING, BOOSTING }
var current_state: State = State.NORMAL

func _physics_process(delta):
	match current_state:
		State.NORMAL:
			_update_normal(delta)
		State.DRIFTING:
			_update_drifting(delta)
		State.BOOSTING:
			_update_boosting(delta)
```
- Pros: Type-safe, clear transitions, easy to extend
- Cons: More verbose than string-based
- Best for: 3-5 states with clear boundaries

**Option B: String-based**
```gdscript
var state: String = "normal"

func _physics_process(delta):
	match state:
		"normal": _update_normal(delta)
		"drifting": _update_drifting(delta)
		"boosting": _update_boosting(delta)
```
- Pros: Simpler syntax, less boilerplate
- Cons: No type safety, typo-prone
- Best for: Prototyping or very simple state machines

**Option C: Boolean flags**
```gdscript
var is_drifting: bool = false
var is_boosting: bool = false
```
- Pros: Simple to check, minimal overhead
- Cons: Complex transitions (multiple flags), harder to maintain
- Best for: 2 states only

**Decision:** Use **Enum-based** (Option A) for Phase 2. Three states with clear transitions, type-safe, and future-proof for Phase 3 integration (visual states will need to query drift/boost state).

### Drift Physics Implementation

**Lateral slide mechanics:**

**Velocity composition approach:**
```gdscript
# Normal steering: velocity = forward * speed
var forward = -global_transform.basis.z
velocity = forward * current_speed

# Drift slide: velocity = forward * speed + lateral * slide
var drift_dir = global_transform.basis.x  # Perpendicular to forward
var slide_amount = sin(deg_to_rad(DRIFT_SLIDE_ANGLE)) * current_speed
velocity = (forward * current_speed) + (drift_dir * slide_amount * drift_direction_sign)
```

Where `drift_direction_sign` = 1 for right drift, -1 for left drift (set on entry).

**Slide angle calculation:**
- DRIFT_SLIDE_ANGLE = 25 degrees (MK8 style: wide arc)
- Lateral component = sin(angle) * forward_speed
- Forward component = cos(angle) * forward_speed (automatically from basis)

**Steering during drift:**
- Modify `rotate_y()` amount: `turn_amount *= DRIFT_TURN_RATE_MULT` (0.3 = 30%)
- Allows minor trajectory adjustment without canceling drift
- Still accumulates in `current_turn` variable for smooth transitions

**Speed retention:**
- On drift entry: `drift_entry_speed = current_speed * DRIFT_SPEED_RETENTION` (0.95)
- During drift: lock speed to `drift_entry_speed` (no acceleration/braking)
- On exit: restore to `current_speed` (may have changed from boost)

### Timer Systems in GDScript

**Drift duration tracking:**

**Option A: Delta accumulation (RECOMMENDED)**
```gdscript
var drift_timer: float = 0.0

func _update_drifting(delta):
	drift_timer += delta
	
	# Check tier thresholds
	if drift_timer >= TIER3_TIME and current_tier < 3:
		current_tier = 3
	elif drift_timer >= TIER2_TIME and current_tier < 2:
		current_tier = 2
	elif drift_timer >= TIER1_TIME and current_tier < 1:
		current_tier = 1
```
- Pros: Simple, deterministic, easy to pause/resume
- Cons: Accumulates floating-point error (negligible for short durations)
- Best for: Game time tracking (respects pause, time_scale)

**Option B: Time.get_ticks_msec()**
```gdscript
var drift_start_time: int = 0

func _enter_drift():
	drift_start_time = Time.get_ticks_msec()

func _update_drifting(delta):
	var elapsed = (Time.get_ticks_msec() - drift_start_time) / 1000.0
```
- Pros: Precise, no accumulation error
- Cons: Ignores pause/time_scale, integer overflow (rare)
- Best for: Real-time measurements (network sync, performance timing)

**Decision:** Use **Delta accumulation** (Option A) for Phase 2. Respects pause (future menu feature) and simpler logic. Tier thresholds (0.5s, 1.5s, 3.0s) are short enough that floating-point error is negligible.

**Boost decay tracking:**
```gdscript
var boost_timer: float = 0.0
var boost_multiplier: float = 1.0

func _update_boosting(delta):
	boost_timer += delta
	
	# Linear decay from boost_mult to 1.0 over BOOST_DURATION
	var progress = boost_timer / BOOST_DURATION
	boost_multiplier = lerp(initial_boost_mult, 1.0, progress)
	
	if boost_timer >= BOOST_DURATION:
		_exit_boost()
```

Uses `lerp()` for smooth decay (same pattern as Phase 1 wheel mesh interpolation).

### Tier Progression Logic

**Threshold-based with no regression:**

```gdscript
var current_tier: int = 0  # 0 = no tier, 1-3 = blue/orange/pink

func _update_tier(elapsed_time: float):
	# Only progress forward, never backward
	if elapsed_time >= TIER3_TIME and current_tier < 3:
		current_tier = 3
		# TODO Phase 3: trigger pink spark effect
	elif elapsed_time >= TIER2_TIME and current_tier < 2:
		current_tier = 2
		# TODO Phase 3: trigger orange spark effect
	elif elapsed_time >= TIER1_TIME and current_tier < 1:
		current_tier = 1
		# TODO Phase 3: trigger blue spark effect
```

**Why this order (highest first):**
- Checks tier 3 first: ensures progression to highest tier reached
- No else-if chain issues: once tier 3 reached, other checks skipped
- Future-proof: Phase 3 can hook into tier change events

**Tier reset on drift exit:**
```gdscript
func _exit_drift():
	var boost_mult = _get_boost_for_tier(current_tier)
	_apply_boost(boost_mult)
	current_tier = 0  # Reset for next drift
	drift_timer = 0.0
```

### Input Detection Patterns

**Combination input checking:**

**MK8 requirement:** Brake + turn held simultaneously

```gdscript
func _check_drift_conditions() -> bool:
	var brake_held = Input.is_action_pressed("ui_down")
	var turn_left = Input.is_action_pressed("ui_left")
	var turn_right = Input.is_action_pressed("ui_right")
	var has_turn_input = turn_left or turn_right
	
	return (
		brake_held and
		has_turn_input and
		is_grounded and
		current_speed >= DRIFT_MIN_SPEED and
		current_state == State.NORMAL  # Not already drifting/boosting
	)
```

**Drift direction detection:**
```gdscript
func _get_drift_direction() -> float:
	if Input.is_action_pressed("ui_left"):
		return -1.0  # Left drift
	elif Input.is_action_pressed("ui_right"):
		return 1.0  # Right drift
	return 0.0
```

Stored on drift entry, used for lateral slide direction.

**Exit detection:**
```gdscript
func _check_drift_exit() -> bool:
	var brake_released = not Input.is_action_pressed("ui_down")
	return brake_released
```

Simpler than entry: just check brake release.

### Boost Speed Modification

**Applying boost multiplier:**

**Phase 1 uses:** `velocity = forward * current_speed`

**Phase 2 extends:**
```gdscript
# During boost state
var effective_speed = current_speed * boost_multiplier
velocity = forward * effective_speed
```

**Boost tier mapping:**
```gdscript
func _get_boost_for_tier(tier: int) -> float:
	match tier:
		1: return TIER1_BOOST  # 1.10 (10%)
		2: return TIER2_BOOST  # 1.20 (20%)
		3: return TIER3_BOOST  # 1.35 (35%)
		_: return 1.0  # No tier = no boost
```

**Decay implementation:**
```gdscript
var initial_boost_mult: float = 1.0  # Set on boost entry

func _update_boosting(delta):
	boost_timer += delta
	var progress = clamp(boost_timer / BOOST_DURATION, 0.0, 1.0)
	boost_multiplier = lerp(initial_boost_mult, 1.0, progress)
	
	if progress >= 1.0:
		_exit_boost()
```

Linear lerp from tier multiplier (1.10/1.20/1.35) to 1.0 over 1.5 seconds.

### Cancel Conditions

**Airborne detection:**
```gdscript
if current_state == State.DRIFTING and not is_grounded:
	_cancel_drift(award_boost=false)
```

**Speed too low:**
```gdscript
if current_state == State.DRIFTING and current_speed < 10.0:
	_cancel_drift(award_boost=false)
```

**Wall collision (optional - detect from velocity):**
```gdscript
var prev_velocity: Vector3 = velocity

func _physics_process(delta):
	move_and_slide()
	
	# Detect sudden stop (wall hit)
	if current_state == State.DRIFTING:
		var velocity_loss = prev_velocity.length() - velocity.length()
		if velocity_loss > 20.0:  # Sudden deceleration
			_cancel_drift(award_boost=true)  # Hit wall, but award boost if tier reached
	
	prev_velocity = velocity
```

### Integration with Phase 1

**Modifying existing methods:**

**_handle_steering modification:**
```gdscript
func _handle_steering(delta: float, steer_input: float) -> void:
	# Adjust turn speed based on state
	var effective_turn_speed = TURN_SPEED
	if current_state == State.DRIFTING:
		effective_turn_speed *= DRIFT_TURN_RATE_MULT  # 0.3
	
	current_turn = move_toward(current_turn, steer_input, effective_turn_speed * delta)
	var turn_amount = current_turn * MAX_TURN_RATE * delta
	rotate_y(turn_amount)
```

**_handle_acceleration modification:**
```gdscript
func _handle_acceleration(delta: float, throttle_input: float, brake_input: bool) -> void:
	# Skip acceleration logic during drift (speed locked)
	if current_state == State.DRIFTING:
		return
	
	# Boost overrides normal acceleration
	if current_state == State.BOOSTING:
		# Speed modification handled in velocity calculation
		return
	
	# ... existing Phase 1 acceleration logic ...
```

**_physics_process integration:**
```gdscript
func _physics_process(delta: float) -> void:
	# Input detection
	_check_and_trigger_drift()
	
	# State updates
	match current_state:
		State.NORMAL:
			_handle_steering(delta, steer_input)
			_handle_acceleration(delta, throttle, brake)
		State.DRIFTING:
			_update_drifting(delta)
			_check_drift_exit()
		State.BOOSTING:
			_update_boosting(delta)
			_handle_steering(delta, steer_input)
	
	# Ground detection (unchanged)
	_update_ground_state()
	
	# Velocity calculation (state-aware)
	_calculate_velocity()
	
	# Movement
	if not is_grounded:
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
		_align_to_ground(delta)
	
	move_and_slide()
	_update_wheel_meshes(delta)
	
	# Existing reset check
	_check_reset()
```

## Technical Approach

### Implementation Strategy

**Phase 2 breakdown:**
1. **Add state machine foundation** - Enum, state tracking, basic transitions
2. **Implement drift entry** - Input detection, condition checking, state transition
3. **Implement drift physics** - Lateral slide, reduced steering, speed lock
4. **Implement tier system** - Timer, threshold checking, progression logic
5. **Implement boost mechanics** - Multiplier application, decay, duration tracking
6. **Integrate and tune** - Test all transitions, tune constants for feel

**Extension strategy (non-destructive):**
- Add new state variables (don't remove Phase 1 vars)
- Modify existing methods with state checks (preserve fallback to Phase 1 behavior)
- Add new methods (_enter_drift, _update_drifting, etc.)
- Keep Phase 1 constants intact, add Phase 2 constants alongside

### Constants to Define

```gdscript
# Drift entry
@export_group("Drift Entry")
@export var DRIFT_MIN_SPEED = 15.0        ## Minimum speed to enter drift
@export var DRIFT_SPEED_RETENTION = 0.95  ## Speed multiplier during drift (95%)

# Drift physics
@export_group("Drift Physics")
@export var DRIFT_SLIDE_ANGLE = 25.0       ## Lateral slide angle (degrees)
@export var DRIFT_TURN_RATE_MULT = 0.3     ## Steering strength during drift (30%)

# Boost tiers
@export_group("Boost Tiers")
@export var TIER1_TIME = 0.5               ## Blue spark threshold (seconds)
@export var TIER2_TIME = 1.5               ## Orange spark threshold (seconds)
@export var TIER3_TIME = 3.0               ## Pink spark threshold (seconds)
@export var TIER1_BOOST = 1.10             ## Tier 1 boost multiplier (110% speed)
@export var TIER2_BOOST = 1.20             ## Tier 2 boost multiplier (120% speed)
@export var TIER3_BOOST = 1.35             ## Tier 3 boost multiplier (135% speed)

# Boost behavior
@export_group("Boost")
@export var BOOST_DURATION = 1.5           ## Boost duration (seconds)
```

All @export for runtime tuning (same pattern as Phase 1).

### State Variables to Add

```gdscript
# State machine
enum State { NORMAL, DRIFTING, BOOSTING }
var current_state: State = State.NORMAL

# Drift state
var drift_timer: float = 0.0
var current_tier: int = 0  # 0-3
var drift_direction: float = 0.0  # -1 (left) or 1 (right)
var drift_entry_speed: float = 0.0

# Boost state
var boost_timer: float = 0.0
var boost_multiplier: float = 1.0
var initial_boost_mult: float = 1.0
```

### Testing Strategy

**Unit validation (per-task):**
- Enum compilation: script compiles without errors
- State transitions: can enter/exit each state
- Timer accuracy: drift timer matches expected values (0.5s, 1.5s, 3.0s)
- Boost decay: multiplier lerps correctly from tier value to 1.0

**Behavior validation (Phase 2 completion):**
- DRIFT-01: Brake + turn triggers drift entry
- DRIFT-02: Kart slides laterally (visible arc trajectory)
- DRIFT-03: Three tiers reached at correct times
- DRIFT-04-06: Timing thresholds validated (±0.1s tolerance)
- DRIFT-07: Brake release exits drift, applies boost
- DRIFT-08: Boost multipliers correct (measure speed increase)

**Integration validation:**
- Phase 1 behavior preserved in Normal state
- No regressions to steering/acceleration/ground alignment
- Can chain: drift → boost → normal → drift

**Manual test cases:**
1. **Quick drift (Tier 1):** Hold drift for 0.5s, release, observe ~10% speed boost
2. **Medium drift (Tier 2):** Hold drift for 1.5s, release, observe ~20% speed boost
3. **Long drift (Tier 3):** Hold drift for 3.0s, release, observe ~35% speed boost
4. **Chained drifts:** Boost → normal → drift → boost (test sequential chaining)
5. **Cancel airborne:** Jump during drift, drift cancels, no boost
6. **Cancel slow:** Drift at high speed, let speed decay, drift cancels below 10 u/s
7. **Steering during drift:** Verify reduced turn rate (30%), can still adjust trajectory

## Risk Assessment

### High Confidence (>90%)

- ✓ Enum state machine well-suited for 3 states
- ✓ Delta accumulation reliable for short timers (0.5-3.0s)
- ✓ Lerp-based boost decay proven in Phase 1
- ✓ Input detection straightforward (brake + turn check)
- ✓ Phase 1 integration points clear (current_speed, current_turn variables)

### Medium Confidence (60-90%)

- ⚠ Lateral slide physics feel (slide angle, velocity composition)
  - Mitigation: @export DRIFT_SLIDE_ANGLE for runtime tuning
  - May need 2-3 iterations to match MK8 feel
  
- ⚠ Boost timing feel (1.5s duration may be too long/short)
  - Mitigation: @export BOOST_DURATION for tuning
  - Can adjust based on playtesting

- ⚠ Tier progression feel (thresholds 0.5/1.5/3.0s may need adjustment)
  - Mitigation: @export TIERx_TIME constants
  - Validate against MK8 reference if possible

### Low Confidence (<60%)

- ⚠ Drift entry responsiveness (instant vs 1-frame delay)
  - Input detection in _physics_process may have frame latency
  - Mitigation: Test on 60 FPS target, adjust if needed

### Identified Risks

1. **Drift feel is subjective** (medium risk)
   - Same as Phase 1: multiple tuning iterations likely
   - Mitigation: Comprehensive @export constants, clear test cases
   - MK8 reference provides objective target

2. **State transitions complexity** (low risk)
   - Three states with clear boundaries
   - Mitigation: Explicit state enum, match statement
   - Well-tested pattern in game development

3. **Boost stacking edge cases** (low risk)
   - Block drift entry while boosting (prevents stacking)
   - Mitigation: State check in _check_drift_conditions()

## References

### GDScript Documentation
- Enums: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#enums
- lerp(): https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#class-globalscope-method-lerp
- Time: https://docs.godotengine.org/en/stable/classes/class_time.html

### Phase 1 Patterns
- `entities/car/arcade_car.gd` - current_speed/current_turn variables, move_toward() usage
- Smooth interpolation pattern (lines 114, 76) - reuse for boost decay

### Project Context
- `.planning/phases/02-drift-boost-system/02-CONTEXT.md` - MK8-based decisions
- `.planning/REQUIREMENTS.md` - DRIFT-01 through DRIFT-08 acceptance criteria

---

*Research complete: 2026-03-22*
*Confidence: HIGH (>85%) - Clear implementation path with proven patterns*
