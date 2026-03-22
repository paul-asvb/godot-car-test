# Phase 3: Visual Feedback - Research

**Created:** 2026-03-22
**Phase:** 03-visual-feedback
**Focus:** GPUParticles3D systems, dynamic materials, camera scripting, web performance

## Summary

Research into implementing visual feedback for drift/boost system. Key findings: GPUParticles3D with process materials enables color switching, particle spawn should be in world space (not local), camera smoothing requires position lerp in script, and web builds handle 200-300 GPU particles well but need count limits.

## Domain Knowledge

### Godot Particle Systems

**GPUParticles3D vs CPUParticles3D:**

**GPUParticles3D (RECOMMENDED for Phase 3):**
- Pros: GPU-accelerated, handles 100s of particles well, no CPU overhead
- Cons: Less flexible than CPU, shader-based materials only
- Best for: Web builds, high particle counts, simple behaviors
- Performance: 200-300 particles = minimal impact

**CPUParticles3D:**
- Pros: More flexible, easier to script, fallback for older devices
- Cons: CPU overhead, doesn't scale to high counts
- Best for: Complex behaviors, low particle counts
- Performance: 50-100 particles max for 60 FPS

**Decision:** Use **GPUParticles3D** for all Phase 3 effects. Web build constraint (POLISH-04/05) makes GPU particles essential for performance.

### Particle Configuration

**Core properties:**
```gdscript
# Emission
emitting = true/false           # Start/stop emission
amount = 30                     # Particles per second
lifetime = 0.5                  # How long each particle lives
one_shot = false                # Continuous emission

# Transform
local_coords = false            # IMPORTANT: Use world space for moving emitter
explosiveness = 0.0             # 0 = steady stream, 1 = burst

# Draw
draw_pass_1 = QuadMesh.new()    # Particle shape (quad = billboard)
```

**Key insight for moving objects:**
- **local_coords = false**: Particles spawn in world space, stay where spawned
- Good for: Trails that stay behind kart (drift sparks, boost flames)
- **local_coords = true**: Particles move with parent
- Good for: Aura effects that follow kart (not needed in Phase 3)

### Dynamic Material Color Switching

**Approach: Update process_material colors at runtime**

```gdscript
# Get particle material
var mat: ParticleProcessMaterial = particles.process_material

# Change color
mat.color = Color(1.0, 0.5, 0.1)  # Orange

# Or use color ramp for gradients
var gradient = Gradient.new()
gradient.add_point(0.0, Color(1.0, 0.6, 0.1))  # Orange start
gradient.add_point(1.0, Color(0.5, 0.1, 0.0))  # Dark red end
mat.color_ramp = GradientTexture1D.new()
mat.color_ramp.gradient = gradient
```

**For drift sparks (tier colors):**
```gdscript
func _update_spark_color():
	var color = _get_tier_color(current_tier)
	for spark in drift_sparks:
		var mat: ParticleProcessMaterial = spark.process_material
		mat.color = color

func _get_tier_color(tier: int) -> Color:
	match tier:
		1: return Color(0.3, 0.5, 1.0)   # Blue
		2: return Color(1.0, 0.5, 0.1)   # Orange
		3: return Color(1.0, 0.2, 0.8)   # Pink
		_: return Color.WHITE
```

**Performance note:**
- Material property changes are fast (no shader compilation)
- Can update every frame without issue
- Changes visible immediately (same frame)

### Camera Smoothing in GDScript

**Approach: Script-based position lerp**

**Option A: Direct position lerp (RECOMMENDED)**
```gdscript
extends Camera3D

var base_offset = Vector3(0, 3, 5)  # Default camera position
var drift_offset = Vector3.ZERO     # Additional offset during drift
var smoothing = 0.15                # Lerp factor (0.1-0.2 range)

func _process(delta):
	var target_pos = base_offset + drift_offset
	position = position.lerp(target_pos, smoothing)
```

**Option B: SpringArm3D node**
- Adds SpringArm3D as parent of Camera3D
- Built-in smoothing via spring_length and margin
- Pros: No scripting, automatic collision avoidance
- Cons: More complex hierarchy, harder to add drift offset

**Decision:** Use **Direct position lerp** (Option A). Simpler, gives full control over drift offset behavior, no extra nodes needed.

**Drift offset calculation:**
```gdscript
# In car script (arcade_car.gd)
func _update_camera_offset(delta):
	var target_offset = Vector3.ZERO
	
	if current_state == State.DRIFTING:
		# Shift camera opposite drift direction (better turn visibility)
		target_offset.x = -drift_direction * 1.5  # 1.5 units lateral
	
	# Smooth transition
	camera_drift_offset = camera_drift_offset.lerp(target_offset, 5.0 * delta)
	camera.position = camera_base_offset + camera_drift_offset
```

### Particle Emission Control

**Starting/stopping emission:**

```gdscript
# Drift sparks (all 4 wheels)
for spark in drift_sparks:
	spark.emitting = (current_state == State.DRIFTING)

# Boost flames
boost_flames.emitting = (current_state == State.BOOSTING)

# Speed lines (speed threshold)
speed_lines.emitting = (current_speed > 25.0)
```

**Smooth fade in/out (optional):**
- Particles naturally fade as emission stops (existing particles finish lifetime)
- No instant pop (GPUParticles3D handles gracefully)
- Can adjust lifetime for longer trails

### Scene Hierarchy

**Current structure:**
```
Car (CharacterBody3D)
├── Camera3D
├── MeshInstance3D
├── CollisionShape3D
├── WheelFL (RayCast3D)
│   └── WheelMeshFL
├── WheelFR (RayCast3D)
│   └── WheelMeshFR
├── WheelRL (RayCast3D)
│   └── WheelMeshRL
└── WheelRR (RayCast3D)
    └── WheelMeshRR
```

**Phase 3 additions:**
```
Car (CharacterBody3D)
├── Camera3D
├── MeshInstance3D
├── CollisionShape3D
├── WheelFL (RayCast3D)
│   ├── WheelMeshFL
│   └── DriftSparkFL (GPUParticles3D)  ← NEW
├── WheelFR (RayCast3D)
│   ├── WheelMeshFR
│   └── DriftSparkFR (GPUParticles3D)  ← NEW
├── WheelRL (RayCast3D)
│   ├── WheelMeshRL
│   └── DriftSparkRL (GPUParticles3D)  ← NEW
├── WheelRR (RayCast3D)
│   ├── WheelMeshRR
│   └── DriftSparkRR (GPUParticles3D)  ← NEW
├── BoostFlames (GPUParticles3D)       ← NEW
└── SpeedLines (GPUParticles3D)        ← NEW
```

**Organization:**
- Drift sparks: Children of wheel nodes (spawn at wheel position)
- Boost flames: Child of Car (spawn at kart rear)
- Speed lines: Child of Car or Camera (spawn near camera)

## Technical Approach

### Implementation Strategy

**Phase 3 breakdown:**
1. **Create particle scenes/resources** - Set up GPUParticles3D with materials
2. **Add particles to main.tscn** - Integrate into scene hierarchy
3. **Implement drift spark control** - Emission toggle and color switching
4. **Implement boost flame control** - Emission toggle and intensity
5. **Implement speed line control** - Emission and intensity scaling
6. **Add camera script** - Smooth following and drift offset
7. **Tune and optimize** - Adjust counts/lifetimes for web performance

**Integration with Phase 2:**
- Read state variables from arcade_car.gd
- No modifications to core physics
- Visual effects are additive (can disable without breaking gameplay)

### Particle Material Templates

**Drift spark material (ParticleProcessMaterial):**
```gdscript
var spark_mat = ParticleProcessMaterial.new()

# Emission
spark_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
spark_mat.direction = Vector3(0, 0.5, -1)  # Behind and slightly up
spark_mat.spread = 30.0                    # Cone spread

# Physics
spark_mat.initial_velocity_min = 5.0
spark_mat.initial_velocity_max = 8.0
spark_mat.gravity = Vector3(0, -9.8, 0)    # Fall naturally

# Appearance
spark_mat.color = Color(0.3, 0.5, 1.0)     # Blue (tier 1)
spark_mat.scale_min = 0.1
spark_mat.scale_max = 0.2

# Fade
spark_mat.alpha_curve = create_fade_curve()  # 1.0 → 0.0
```

**Boost flame material (ParticleProcessMaterial):**
```gdscript
var flame_mat = ParticleProcessMaterial.new()

# Emission
flame_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
flame_mat.emission_sphere_radius = 0.3

# Physics
flame_mat.initial_velocity_min = 2.0
flame_mat.initial_velocity_max = 4.0
flame_mat.gravity = Vector3(0, 2.0, 0)     # Rise slightly

# Appearance (gradient: orange → red → dark)
var gradient = Gradient.new()
gradient.add_point(0.0, Color(1.0, 0.6, 0.1))  # Bright orange
gradient.add_point(0.5, Color(1.0, 0.2, 0.0))  # Red
gradient.add_point(1.0, Color(0.2, 0.0, 0.0))  # Dark
flame_mat.color_ramp = create_gradient_texture(gradient)
flame_mat.scale_min = 0.3
flame_mat.scale_max = 0.5
```

### Testing Strategy

**Visual validation (all manual):**
- VFX-01: Drift sparks visible from wheels during drift
- VFX-02: Spark color changes on tier progression (blue → orange → pink)
- VFX-03: Boost flames visible during boost state
- VFX-04: Speed lines visible at high speed (25+ u/s)
- VFX-05: Camera follows smoothly (no jitter)
- VFX-06: Camera shifts during drift (better turn visibility)

**Performance validation:**
- Monitor FPS: Should maintain 60 FPS with all effects active
- Particle count: Total active particles < 300
- Web build: Test in browser (if available)

**Integration validation:**
- Phase 1/2 behavior unchanged (visual only)
- Particles don't affect physics
- Can disable effects without breaking gameplay

## Risk Assessment

### High Confidence (>85%)

- ✓ GPUParticles3D well-documented and proven for racing games
- ✓ Color switching via material properties straightforward
- ✓ Camera lerp pattern simple and reliable
- ✓ State hooks from Phase 2 perfect for particle triggers

### Medium Confidence (60-85%)

- ⚠ Particle appearance tuning (colors, sizes, lifetimes)
  - Mitigation: @export constants, quick iteration
  - May need 2-3 passes to match MK8 look
  
- ⚠ Camera drift offset feel (amount, transition speed)
  - Mitigation: Tunable offset distance and lerp speed
  - Test with different drift arcs

- ⚠ Web performance with all particles active
  - Mitigation: Particle count limits, GPU particles only
  - Profile if FPS drops below 60

### Low Confidence (<60%)

- ⚠ Speed lines visibility (may be too subtle or too distracting)
  - Mitigation: Make toggleable, tune intensity
  - Can defer to Phase 12 if problematic

### Identified Risks

1. **Visual clutter** (low risk)
   - Too many effects at once may be overwhelming
   - Mitigation: Tune particle counts conservatively
   - Speed lines optional (can reduce/remove)

2. **Performance on web** (medium risk)
   - 300 particles may impact FPS on slower devices
   - Mitigation: Already using GPU particles, can reduce counts
   - Phase 12 will optimize further if needed

3. **Color visibility** (low risk)
   - Tier colors must be distinguishable
   - Mitigation: Use high-contrast colors (blue/orange/pink)
   - Test in different lighting conditions

## References

### Godot Documentation
- GPUParticles3D: https://docs.godotengine.org/en/stable/classes/class_gpuparticles3d.html
- ParticleProcessMaterial: https://docs.godotengine.org/en/stable/classes/class_particleprocessmaterial.html
- Camera3D: https://docs.godotengine.org/en/stable/classes/class_camera3d.html

### Phase 2 Integration
- `entities/car/arcade_car.gd` - State variables (current_state, current_tier, drift_direction)
- Wheel nodes provide spawn positions
- State machine provides emission triggers

### Project Context
- `.planning/phases/03-visual-feedback/03-CONTEXT.md` - VFX decisions
- `.planning/REQUIREMENTS.md` - VFX-01 through VFX-06 acceptance criteria
- `.planning/PROJECT.md` - Web build performance constraint

---

*Research complete: 2026-03-22*
*Confidence: HIGH (>85%) - Straightforward particle implementation with proven patterns*
