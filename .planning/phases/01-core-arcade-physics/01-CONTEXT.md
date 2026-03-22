# Phase 1: Core Arcade Physics - Context

**Gathered:** 2026-03-22
**Status:** Ready for planning

<domain>
## Phase Boundary

Replace RigidBody3D physics with CharacterBody3D arcade movement that feels responsive and fun. Kart must respond immediately to input with tight control, reach high speed quickly, stay aligned to ground surface, and maintain speed through turns.

</domain>

<decisions>
## Implementation Decisions

### Acceleration Curve
- Fast ramp-up (MK8 style): reach max speed in ~1.5-2 seconds
- Smooth coasting when throttle released (momentum-based feel)
- Brake + reverse: holding brake when stopped switches to reverse gear
- Top speed: 35-40 units/second (fast arcade feel for 60x80 unit environment)

### Steering Feel
- Smooth interpolation between input and turn angle (current STEER_SPEED approach)
- Moderate turn radius at full speed (MK8 style) - need drift/brake for hairpins
- Speed-dependent steering: turn radius scales with speed
- Same sensitivity for keyboard and gamepad (no analog advantage)

### Turn Speed Handling
- No speed loss through turns (maintain full speed)
- No grip limit (kart always turns as commanded, no unintentional sliding)
- Turn behavior identical whether accelerating or coasting

### Ground Hugging Behavior
- Slight tilt freedom: kart mostly aligns to surface but can tilt on slopes
- Natural jump physics: can launch off ramps with ballistic arc, dampened landing
- Limited air control: can adjust direction slightly in air but mostly committed to trajectory
- Multiple raycasts for ground detection (4 rays like current wheel system for accuracy)

### Claude's Discretion
- Exact acceleration/deceleration constants (tune to hit ~1.5-2s to max speed)
- Steering interpolation speed (balance responsiveness vs smoothness)
- Ground alignment interpolation rate (smooth surface following)
- Jump landing dampening values
- Air control influence strength

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

No external specs — requirements fully captured in decisions above and project requirements.

### Project Requirements
- `.planning/REQUIREMENTS.md` — PHYS-01 through PHYS-05 define acceptance criteria
- `.planning/PROJECT.md` — Design direction emphasizes "feel over realism"

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Wheel raycast system** (`car.gd` lines 22-27, 55-106): 4 RayCast3D nodes already positioned at wheel locations. Can repurpose for ground detection in CharacterBody3D implementation.
- **Wheel mesh smoothing** (`car.gd` lines 73-76): Smooth lerp pattern for visual updates — can reuse for ground alignment interpolation.
- **Input handling** (`car.gd` lines 36-53): Existing input actions (ui_left, ui_right, ui_up, ui_down, ui_cancel) already mapped. Keep same action names for compatibility.
- **Reset mechanism** (`car.gd` lines 113-123): Out-of-bounds detection and position reset already implemented. Will need to adapt for CharacterBody3D.

### Established Patterns
- **Smooth interpolation preference**: Code uses `move_toward()` for steering (line 47) and `lerp()` for wheel visuals (line 76). Continue this pattern for arcade feel.
- **Physics in `_physics_process()`**: All movement logic in physics frame. Keep this structure.
- **Scene return mechanism**: ESC key returns to menu (lines 37-38). Maintain this pattern.

### Integration Points
- **Main scene** (`scenes/main.tscn`): Car entity instantiated here. Will need to update scene to use new CharacterBody3D-based car.
- **Environment**: Current obstacle course (60x80 unit ground, walls at boundaries, ramps). Can use for testing arcade physics before Phase 4 track building.
- **Camera**: Camera is child of car node. Will continue to follow kart automatically with new physics.

</code_context>

<specifics>
## Specific Ideas

- "Fast ramp (MK8 style)" indicates preference for Mario Kart 8 as reference feel
- High speed preference (35-40 u/s) suggests races should feel fast-paced
- No grip limit + no speed loss in turns = pure arcade control (F-Zero/early MK style)
- Limited air control matches most kart racers (not platformer-like)

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope. All suggestions related to arcade movement implementation.

</deferred>

---

*Phase: 01-core-arcade-physics*
*Context gathered: 2026-03-22*
