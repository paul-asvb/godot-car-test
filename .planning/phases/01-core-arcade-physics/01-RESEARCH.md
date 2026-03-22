# Phase 1: Core Arcade Physics - Research

**Created:** 2026-03-22
**Phase:** 01-core-arcade-physics
**Focus:** CharacterBody3D arcade movement, ground detection, and responsive controls

## Summary

Research into replacing RigidBody3D physics with CharacterBody3D for arcade-style kart racing. Key findings: CharacterBody3D's `move_and_slide()` is ideal for responsive arcade control, existing raycast system can be reused for ground detection, and Mario Kart 8-style feel requires fast acceleration curves with no grip simulation.

## Domain Knowledge

### CharacterBody3D vs RigidBody3D

**CharacterBody3D advantages for arcade racing:**
- Direct velocity control (no force calculations)
- Built-in collision response via `move_and_slide()`
- Frame-perfect input response (no physics solver delay)
- Simpler to tune (velocity values instead of forces/masses)

**Key methods:**
- `move_and_slide()` - Moves body and handles collisions automatically
- `velocity` property - Direct velocity control (Vector3)
- `is_on_floor()` - Ground detection (though we'll use custom raycasts)

**Migration path from current code:**
- Replace `extends RigidBody3D` with `extends CharacterBody3D`
- Remove: `apply_force()`, `linear_velocity`, `angular_velocity`, mass properties
- Keep: Raycasts for wheels, input handling, mesh updates
- Transform spring-damper suspension into direct velocity control

### Arcade Movement Patterns

**Acceleration curves (MK8 style):**
- Linear acceleration with cap: `speed = min(speed + ACCEL * delta, MAX_SPEED)`
- Fast ramp-up: 0 to max in 1.5-2 seconds means `ACCEL = MAX_SPEED / 1.75`
- Smooth coast: `speed = move_toward(speed, 0, DECEL * delta)`
- No friction simulation - explicit deceleration values

**Steering approaches:**
- **Option A: Instant rotation** - `rotate_y(input * TURN_RATE * delta)`
  - Pros: Maximally responsive
  - Cons: Can feel twitchy, hard to control precisely
- **Option B: Interpolated steering** (RECOMMENDED) - Current code pattern
  - `current_turn = move_toward(current_turn, target, STEER_SPEED * delta)`
  - Pros: Smooth, predictable, works well for keyboard + gamepad
  - Cons: Slight input lag (acceptable for arcade feel)
- **Decision:** Keep current interpolation pattern - already feels good

**Speed through turns:**
- No grip simulation → no speed loss
- Turn rate independent of speed (can adjust if needed)
- Forward velocity maintained regardless of rotation

### Ground Detection & Alignment

**Raycast-based ground detection:**
- Existing system: 4 RayCast3D nodes at wheel positions
- Pattern: Cast downward, check `is_colliding()`, get `get_collision_normal()`
- For alignment: Average normals from all hitting rays

**Surface alignment methods:**
- **Basis interpolation** (RECOMMENDED):
  ```gdscript
  var up = ground_normal.normalized()
  var forward = -global_transform.basis.z
  forward = forward - up * forward.dot(up)  # Project onto plane
  forward = forward.normalized()
  var right = forward.cross(up)
  var target_basis = Basis(right, up, -forward)
  transform.basis = transform.basis.slerp(target_basis, ALIGN_SPEED * delta)
  ```
- Smooth interpolation prevents snapping on uneven terrain
- `ALIGN_SPEED` constant controls responsiveness (typical: 5.0-10.0)

**Height adjustment:**
- Snap to ground: `position.y = hit_point.y + HOVER_HEIGHT`
- Or smooth: `position.y = lerp(position.y, target_y, SNAP_SPEED * delta)`
- Slight hover (0.1-0.2 units) prevents ground friction

### Jump & Air Handling

**Natural jump physics:**
- When `is_grounded == false`: Apply gravity to velocity.y
- `velocity.y -= GRAVITY * delta` (typical GRAVITY: 20-30)
- Maintains horizontal velocity → ballistic arc

**Air control:**
- Reduce turn rate: `effective_turn = TURN_RATE * AIR_CONTROL_FACTOR`
- Typical `AIR_CONTROL_FACTOR`: 0.3-0.5 (30-50% of ground turning)
- Allows minor adjustments but mostly committed trajectory

**Landing:**
- Detect transition: `was_airborne and is_grounded`
- Dampen vertical velocity: `velocity.y *= 0.2` (absorb impact)
- Resume ground alignment

### Performance Considerations

**CharacterBody3D is lighter than RigidBody3D:**
- No physics solver iterations
- No force accumulation
- No angular velocity calculations

**Existing performance patterns to keep:**
- Wheel mesh lerp (line 76) - already optimized
- Single `_physics_process` loop - good practice

**For Phase 8 (splitscreen):**
- CharacterBody3D scales better with multiple instances
- Each viewport can run physics independently

## Technical Approach

### Implementation Strategy

**Phase 1 breakdown:**
1. **Create new arcade_car.gd** - Extend CharacterBody3D
2. **Port input handling** - Reuse existing input actions
3. **Implement acceleration system** - Replace force-based drive with velocity control
4. **Implement steering** - Keep current interpolation pattern
5. **Port ground detection** - Reuse raycast nodes, adapt logic
6. **Implement ground alignment** - Basis interpolation
7. **Add jump/air handling** - Gravity + air control
8. **Update main scene** - Swap Car node type and script

**Reusable from car.gd:**
- Wheel raycast setup (lines 22-27)
- Input handling pattern (lines 36-53)
- Smooth interpolation (lines 47, 76)
- Reset mechanism (lines 113-123)
- Wheel mesh updates (lines 73-76)

**Remove/replace:**
- All RigidBody3D physics (lines 69-106)
- Spring-damper suspension (lines 4-8, 69-86)
- `apply_force()` calls
- `get_point_velocity()` method

### Constants to Define

```gdscript
# Movement
const MAX_SPEED = 35.0                    # Units/sec (fast arcade feel)
const ACCELERATION = 20.0                 # Reaches max in ~1.75s
const DECELERATION = 8.0                  # Smooth coasting
const BRAKE_FORCE = 25.0                  # Quick stops
const REVERSE_SPEED = 15.0                # Backward driving

# Steering
const TURN_SPEED = 2.5                    # Interpolation rate (reuse pattern)
const AIR_CONTROL = 0.4                   # 40% turn rate in air

# Ground behavior
const GROUND_ALIGN_SPEED = 8.0            # Surface following smoothness
const HOVER_HEIGHT = 0.1                  # Slight lift off ground
const GRAVITY = 25.0                      # Jump/fall feel

# Detection
const RAYCAST_LENGTH = 1.0                # Ground detection range
```

### Scene Changes

**main.tscn modifications:**
- Change Car node: `RigidBody3D` → `CharacterBody3D`
- Update script: `car.gd` → `arcade_car.gd`
- Keep children: WheelFL/FR/RL/RR (RayCast3D nodes), wheel meshes, Camera3D
- Remove: Physics material, mass, center of mass properties (not used by CharacterBody3D)

**No changes needed:**
- Ground/obstacles (StaticBody3D) - collision still works
- Camera (child node) - follows automatically
- Menu return (ESC key) - input handling unchanged

## Validation Architecture

### Testing Strategy

**Validation levels:**

1. **Unit validation** (per-task):
   - Script compiles: `godot --check-only arcade_car.gd`
   - Scene loads: `godot --headless scenes/main.tscn --quit-after 1`

2. **Behavior validation** (Phase 1 completion):
   - PHYS-01: Car is CharacterBody3D → Check scene tree node type
   - PHYS-02: Responsive steering → Manual: Navigate figure-8 smoothly
   - PHYS-03: Fast acceleration → Measure: 0 to max speed < 2 seconds
   - PHYS-04: Ground-hugging → Visual: Kart aligns to ramps
   - PHYS-05: Speed through turns → Measure: Velocity maintained in turns

3. **Integration validation** (Phase 2+ dependencies):
   - Drift system needs: `current_speed` variable, `is_grounded` flag
   - VFX needs: Wheel global positions, velocity vector
   - Verify: Variables are accessible (export or public)

### Manual Test Cases

**Test track: Existing obstacle course**

1. **Straight-line acceleration:**
   - Start from rest
   - Hold forward (ui_up)
   - Verify: Reaches ~35 u/s in 1.5-2 seconds
   - Verify: No overshoot or oscillation

2. **Steering response:**
   - Drive at speed
   - Alternate left/right inputs
   - Verify: Immediate response (no lag)
   - Verify: Smooth transitions (no snapping)

3. **Figure-8 pattern:**
   - Navigate tight turns at speed
   - Verify: Can complete without excessive braking
   - Verify: Speed maintained through curves

4. **Ramp jump:**
   - Drive up ramp at speed
   - Verify: Natural arc trajectory
   - Verify: Smooth landing, no bouncing
   - Verify: Can steer slightly in air

5. **Surface following:**
   - Drive over varied terrain (ramps, bumps)
   - Verify: Kart stays aligned to surface
   - Verify: No snapping or jittering
   - Verify: Wheels visually touch ground

6. **Collision:**
   - Hit walls and obstacles
   - Verify: Kart stops/slides (doesn't pass through)
   - Verify: Can reverse away
   - Verify: No getting stuck

### Automated Checks

**Grep-verifiable conditions:**
- `arcade_car.gd contains "extends CharacterBody3D"`
- `arcade_car.gd contains "move_and_slide()"`
- `arcade_car.gd contains "velocity ="`
- `main.tscn contains 'type="CharacterBody3D"'` (scene file check)

**Command checks:**
- Script validation: `godot --check-only entities/car/arcade_car.gd` exits 0
- Scene validation: `godot --headless --quit-after 1 scenes/main.tscn` exits 0

## Risk Assessment

### High Confidence (>90%)

- ✓ CharacterBody3D suitable for arcade racing (well-documented pattern)
- ✓ Raycast ground detection works (existing code validates approach)
- ✓ Interpolated steering provides good feel (current code already uses it)
- ✓ Migration path clear (CharacterBody3D API simpler than RigidBody3D)

### Medium Confidence (60-90%)

- ⚠ Constant tuning (acceleration, steering, alignment speeds)
  - Mitigation: Make constants `@export` for runtime tweaking
  - Expect 2-3 iteration passes

- ⚠ Ground alignment smoothness on varied terrain
  - Mitigation: Adjustable `GROUND_ALIGN_SPEED` constant
  - May need damping for rough surfaces

### Low Confidence (<60%)

- ⚠ Subjective "arcade feel" matching user expectations
  - Mitigation: Use success criteria from CONTEXT.md as objective measure
  - Phase 1 focuses on foundation; Phase 2 (drift) adds character

### Identified Risks

1. **Feel is subjective** (medium risk)
   - Multiple tuning iterations likely needed
   - Success criteria provide objective targets
   - Early playtesting recommended

2. **Ramp landing behavior** (low risk)
   - Damping values may need adjustment
   - Documented in air handling section

3. **Integration with future phases** (low risk)
   - Drift system (Phase 2) needs state variables
   - VFX (Phase 3) needs velocity/position data
   - Ensure variables are accessible (document in plan)

## References

### Godot Documentation
- CharacterBody3D: https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html
- move_and_slide(): https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html#class-characterbody3d-method-move-and-slide
- RayCast3D: https://docs.godotengine.org/en/stable/classes/class_raycast3d.html

### Existing Code Patterns
- `entities/car/car.gd` - Current RigidBody3D implementation (reference for what to replace)
- Input actions: ui_up, ui_down, ui_left, ui_right, ui_cancel (project.godot)

### Project Context
- `.planning/CONTEXT.md` - User decisions (locked requirements)
- `.planning/REQUIREMENTS.md` - PHYS-01 through PHYS-05 acceptance criteria
- `.planning/ROADMAP.md` - Phase dependencies (Phase 2 builds on this)

---

*Research complete: 2026-03-22*
*Confidence: HIGH (>90%) - Straightforward migration with clear implementation path*
