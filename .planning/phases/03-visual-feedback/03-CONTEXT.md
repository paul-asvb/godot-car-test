# Phase 3: Visual Feedback - Context

**Gathered:** 2026-03-22
**Status:** Ready for planning
**Reference Model:** Mario Kart 8 visual feedback (color-coded sparks, boost flames, speed effects)

<domain>
## Phase Boundary

Add particle effects and camera polish to make drift tiers visible and speed tangible. Players need immediate visual feedback: sparks show current tier (blue/orange/pink), boost flames show boost state, speed lines intensify at high speed, and camera behavior enhances visibility during drifts.

</domain>

<decisions>
## Implementation Decisions

### Drift Spark Effects (VFX-01, VFX-02)

**Particle system:**
- GPUParticles3D nodes at each wheel (4 total)
- Emit only during DRIFTING state
- Spawn location: wheel global positions
- Direction: Behind and slightly outward from wheel

**Tier-based colors:**
- Tier 0: No sparks (no tier reached yet)
- Tier 1 (blue): RGB(0.3, 0.5, 1.0) - bright blue
- Tier 2 (orange): RGB(1.0, 0.5, 0.1) - bright orange
- Tier 3 (pink): RGB(1.0, 0.2, 0.8) - bright magenta/pink

**Particle properties:**
- Lifetime: 0.3-0.5 seconds
- Count: 20-30 particles per second (web performance constraint)
- Size: 0.1-0.2 units (small sparks)
- Fade out: Alpha from 1.0 to 0.0 over lifetime

**Performance:**
- Use GPUParticles3D (GPU-accelerated)
- Limit max particles: 50 per emitter
- Total: 200 particles max (4 wheels * 50)
- Acceptable for web build (Phase 12 optimization)

### Boost Flame Effects (VFX-03)

**Particle system:**
- Single GPUParticles3D node at kart rear
- Emit only during BOOSTING state
- Spawn location: Behind kart center, low position
- Direction: Backward trail

**Flame appearance:**
- Color gradient: Orange → red → dark (fire-like)
- Start: RGB(1.0, 0.6, 0.1) - bright orange
- End: RGB(0.5, 0.1, 0.0) - dark red
- Lifetime: 0.5-0.7 seconds
- Count: 30-40 particles per second
- Size: 0.3-0.5 units (larger than sparks)

**Boost intensity:**
- Particle rate scales with boost_multiplier
- Tier 3 boost: More particles, larger size
- Decay: Particle rate decreases as boost decays

### Speed Lines (VFX-04)

**Implementation approach:**
- GPUParticles3D with line-shaped particles
- Emit from camera position, move backward past camera
- Intensity scales with speed (fade in above 25 u/s)

**Speed line properties:**
- Shape: Elongated quads (streaks)
- Color: White with transparency
- Alpha: Increases with speed (0% at 25 u/s, 100% at MAX_SPEED)
- Speed: Fast backward movement (creates motion blur feel)
- Count: 50-100 particles (lightweight)

**Alternative (if particles too expensive):**
- Post-process shader with radial blur
- Deferred for now (particles simpler)

### Camera Smooth Following (VFX-05)

**Camera behavior:**
- Already child of Car node (follows automatically)
- Add lerp damping for smoothness
- Camera controller script: smooth position/rotation lag

**Smooth following:**
- Position lag: Small offset with lerp (0.1-0.2s behind)
- Rotation lag: Smooth rotation interpolation
- No snapping: All movements interpolated

**Implementation:**
- Camera script or modify Camera3D properties
- SpringArm3D node for distance management (optional)
- Lerp factor: 0.1-0.15 (slower = smoother, faster = more responsive)

### Camera Drift Offset (VFX-06)

**Offset during drift:**
- Horizontal shift: Move camera opposite drift direction
- Drift left: Camera shifts right (better view of turn)
- Drift right: Camera shifts left
- Offset amount: 1-2 units lateral
- Smooth transition: Lerp in/out over 0.2-0.3s

**Purpose:**
- Better visibility: See upcoming turn during drift
- Anticipation feel: Camera movement adds to sense of speed
- MK8 reference: Subtle camera shift during drift

**Implementation:**
- Modify camera position based on current_state and drift_direction
- Add to base camera offset
- Lerp back to center on drift exit

### Claude's Discretion

**Particle tuning:**
- Exact spawn rates (20-40 particles/sec)
- Lifetime values (0.3-0.7 seconds)
- Size ranges (0.1-0.5 units)
- Color exact RGB values (blue/orange/pink shades)
- Emission shapes and directions

**Camera tuning:**
- Lerp factors for smoothness (0.1-0.2)
- Drift offset distance (1-2 units)
- Transition speeds (0.2-0.3s)

**Performance:**
- Particle count limits for web
- GPU vs CPU particles decision
- Draw call optimization

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase 2 Implementation
- `entities/car/arcade_car.gd` — State machine (current_state, current_tier, drift_direction)
- `.planning/phases/02-drift-boost-system/02-CONTEXT.md` — Drift/boost behavior
- `.planning/phases/02-drift-boost-system/PHASE-COMPLETE.md` — Integration points

### Project Requirements
- `.planning/REQUIREMENTS.md` — VFX-01 through VFX-06 define acceptance criteria
- `.planning/PROJECT.md` — Web build constraint (performance critical)

### Reference Material
- Mario Kart 8 visual feedback: Color-coded sparks, boost flames, speed effects
- Godot GPUParticles3D: GPU-accelerated particle system

</canonical_refs>

<code_context>
## Existing Code Integration

### Reusable from Phase 1 & 2

**State access (arcade_car.gd):**
- `current_state` → trigger particles (DRIFTING = sparks, BOOSTING = flames)
- `current_tier` → spark color (0 = none, 1 = blue, 2 = orange, 3 = pink)
- `drift_direction` → could affect spark direction
- `current_speed` → speed line intensity
- `boost_multiplier` → boost flame intensity

**Wheel positions:**
- `wheels` array → wheel global_position for spark spawn points
- 4 wheels = 4 particle emitters

**Camera node:**
- Already exists as child of Car in main.tscn
- Path: $Camera3D
- Can add script or modify transform

### New Components Needed

**Particle nodes (add to Car in main.tscn):**
- `$DriftSparkFL` - GPUParticles3D at front-left wheel
- `$DriftSparkFR` - GPUParticles3D at front-right wheel
- `$DriftSparkRL` - GPUParticles3D at rear-left wheel
- `$DriftSparkRR` - GPUParticles3D at rear-right wheel
- `$BoostFlames` - GPUParticles3D at kart rear
- `$SpeedLines` - GPUParticles3D at camera/kart (optional)

**Particle materials:**
- StandardMaterial3D with transparency
- Billboard mode for camera-facing
- Additive blend for glow effect

**Methods to add (arcade_car.gd):**
- `_update_drift_sparks()` - Control spark emission and color
- `_update_boost_flames()` - Control boost flame emission
- `_update_speed_lines()` - Control speed line intensity
- `_update_camera()` - Handle camera smoothing and drift offset

**Node references to add:**
```gdscript
@onready var drift_sparks = [
	$DriftSparkFL,
	$DriftSparkFR,
	$DriftSparkRL,
	$DriftSparkRR
]
@onready var boost_flames = $BoostFlames
@onready var camera = $Camera3D
```

### Integration Points

**Particle activation:**
- Drift sparks: `emitting = (current_state == State.DRIFTING)`
- Boost flames: `emitting = (current_state == State.BOOSTING)`
- Speed lines: `emitting = (current_speed > 25.0)`

**Color switching:**
```gdscript
func _get_spark_color() -> Color:
	match current_tier:
		1: return Color(0.3, 0.5, 1.0)  # Blue
		2: return Color(1.0, 0.5, 0.1)  # Orange
		3: return Color(1.0, 0.2, 0.8)  # Pink
		_: return Color.WHITE
```

**Camera offset:**
```gdscript
var camera_base_offset = Vector3(0, 3, 5)  # Existing offset
var camera_drift_offset = Vector3.ZERO

func _update_camera(delta):
	if current_state == State.DRIFTING:
		# Shift opposite drift direction
		camera_drift_offset.x = lerp(camera_drift_offset.x, -drift_direction * 1.5, 5.0 * delta)
	else:
		# Return to center
		camera_drift_offset.x = lerp(camera_drift_offset.x, 0.0, 5.0 * delta)
	
	camera.position = camera_base_offset + camera_drift_offset
```

</code_context>

<specifics>
## Specific Ideas

**MK8 visual reference:**
- Drift sparks trail behind wheels (not upward)
- Color change is instant on tier progression
- Boost flames are bright and obvious
- Speed lines appear at high speed only (not always visible)
- Camera movement is subtle (enhances without disorienting)

**Feel priorities:**
- Visual clarity: Player must know current tier without guessing
- Performance: Must maintain 60 FPS with all particles
- Polish: Effects feel premium, not placeholder
- Feedback loop: Visual + gameplay mechanics reinforce each other

**Web build constraints:**
- Particle count limits (200-300 total max)
- GPU particles preferred (CPU too expensive)
- Simple materials (no complex shaders initially)
- Optimize in Phase 12 if needed

</specifics>

<deferred>
## Deferred Ideas

**Not in Phase 3 scope:**
- Tire mark trails on ground → Phase 12: Polish
- Dynamic FOV changes → Phase 12: Polish (camera FOV increases at high speed)
- Screen shake effects → Future consideration
- Particle collision with environment → Unnecessary complexity
- Advanced particle shaders → Keep simple for web build

**Noted for future phases:**
- POLISH-01: Tire marks (Phase 12 will add persistent trail decals)
- POLISH-02: Camera FOV (Phase 12 will add dynamic FOV based on speed)

</deferred>

---

*Phase: 03-visual-feedback*
*Context gathered: 2026-03-22 (Auto-mode: Standard VFX conventions)*
*Reference: Mario Kart 8 visual feedback*
