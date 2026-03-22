# Phase 4: First Race Track - Context

**Gathered:** 2026-03-22
**Status:** Ready for planning
**Reference Model:** Classic kart racing track design (Mario Kart, CTR style)

<domain>
## Phase Boundary

Design and build one complete looping race track optimized for drifting. Track must have varied turn types to test all kart mechanics, checkpoint system for lap validation, clear boundaries to prevent off-track driving, and optimized mesh for web performance (<10k triangles).

</domain>

<decisions>
## Implementation Decisions

### Track Layout

**Loop structure:**
- Complete circuit: Returns to start/finish line
- Lap duration: 1-2 minutes per lap at racing speed
- Length: ~400-600 units (based on 35 u/s average speed)
- Width: 6-8 units (allows 2-3 karts side-by-side for Phase 8)

**Turn variety (per TRACK-02):**
- 2-3 hairpins: 180° tight turns requiring drift (tier 2-3)
- 2-3 chicanes: S-curves for quick direction changes (tier 1)
- 2-3 sweepers: Wide, fast curves maintain speed (optional drift)
- 1-2 straights: High-speed sections for tier 3 boost testing

**Elevation changes:**
- 2-3 ramps/jumps: Test jump physics from Phase 1
- Gentle slopes: Test ground alignment
- Flat sections: Baseline for performance testing

### Track Construction Method

**Approach: Procedural CSGPolygon3D (RECOMMENDED)**
- Use CSGPolygon3D with Path3D for track shape
- Pros: Easy to edit curve, automatic mesh generation, smooth
- Cons: Higher tri count than manual modeling
- Acceptable: Can optimize mesh in Phase 12 if needed

**Alternative: Manual mesh modeling**
- Model in Blender, import as .glb
- Pros: Full control, optimal tri count
- Cons: Harder to iterate, requires external tool
- Deferred: Use procedural for v1, remodel in Phase 12 if needed

**Track surface:**
- Single material: Simple colored/textured surface
- No grip zones yet (all surface has same friction)
- Collision: Track mesh is StaticBody3D with MeshInstance3D

### Checkpoint System

**Implementation: Area3D nodes**
- 8-12 Area3D nodes placed along track
- Each checkpoint has unique ID (0-11)
- Trigger: `body_entered` signal detects kart
- Validation: Track sequence, reject out-of-order

**Checkpoint placement:**
- After every major turn
- Before/after straights
- Strategic locations to prevent shortcuts
- Spaced evenly around lap (every 40-60 units)

**Sequence validation logic:**
```gdscript
var checkpoints_passed = []  # Track which checkpoints hit
var expected_next_checkpoint = 0

func _on_checkpoint_entered(checkpoint_id, body):
	if checkpoint_id == expected_next_checkpoint:
		checkpoints_passed.append(checkpoint_id)
		expected_next_checkpoint = (checkpoint_id + 1) % total_checkpoints
		# Check if lap complete (all checkpoints hit + cross finish line)
```

**Visual design:**
- Invisible to player (Area3D has no mesh)
- Debug mode: Optional colored boxes for development
- Size: Wide enough to guarantee passage (track width + margin)

### Start/Finish Line

**Visual marker:**
- Checkered pattern texture on track
- Or overhead banner/arch (simple mesh)
- Position: Checkpoint 0 location

**Functional:**
- Start/finish is first checkpoint (ID 0)
- Lap increments only after all checkpoints in sequence
- Race completion: Lap 3 + finish line (Phase 5)

### Boundaries and Collision

**Walls/barriers:**
- StaticBody3D with CollisionShape3D
- Height: 2-3 units (taller than kart)
- Positioned at track edges
- Material: Simple colored (reuse existing wall material)

**Off-track zones:**
- No geometry beyond walls (falls to void)
- Kart reset triggers (existing system from Phase 1)
- Alternative: Invisible kill zone Area3D (deferred)

### Performance Optimization

**Triangle budget: <10k (TRACK-07)**
- Track surface: ~3-5k tris
- Walls/barriers: ~2-3k tris
- Decorations: ~2-4k tris (optional)
- Total: 7-12k tris (acceptable for web)

**Optimization techniques:**
- Reuse meshes: Same wall segment repeated
- Low-poly curves: Fewer subdivisions on Path3D
- No decorations initially (add in Phase 11-12 if budget allows)

### Claude's Discretion

**Track design specifics:**
- Exact turn radii and angles
- Checkpoint exact positions (8, 10, or 12 total)
- Wall height (2-3 units)
- Ramp steepness and length
- Track width (6-8 units)
- Surface material colors/textures

**Technical implementation:**
- CSG vs manual mesh decision (use CSG)
- Checkpoint trigger size
- Sequence validation data structure
- Debug visualization approach

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase 1-3 Integration
- `entities/car/arcade_car.gd` — Kart to test track design
- `scenes/main.tscn` — Environment structure (ground, walls)
- `.planning/phases/01-core-arcade-physics/01-CONTEXT.md` — Movement speeds (35 u/s)

### Project Requirements
- `.planning/REQUIREMENTS.md` — TRACK-01 through TRACK-07 define acceptance criteria
- `.planning/PROJECT.md` — Web performance constraint

### Reference Material
- Mario Kart track design: Varied turns, clear boundaries, drift-friendly
- Godot CSGPolygon3D: Path-based track generation

</canonical_refs>

<code_context>
## Existing Code Integration

### Test environment available
- Kart fully functional (Phases 1-3)
- Can drive immediately on new track
- Drift mechanics ready to test on curves

### Scene structure
- `scenes/main.tscn` currently has obstacle course
- Will replace with track scene or add track to main

### Reusable patterns
- StaticBody3D for collision (existing walls)
- Area3D for triggers (similar to future item boxes)
- Material reuse (existing ground/wall materials)

### New components needed

**Track scene/nodes:**
- Track mesh (CSGPolygon3D + Path3D)
- StaticBody3D for collision
- Boundary walls (reuse BoxMesh pattern)

**Checkpoint system:**
- CheckpointManager singleton or script
- 8-12 Area3D nodes along track
- Sequence validation logic
- Lap counter integration (Phase 5 will extend)

**Scene organization options:**
1. Replace main.tscn ground with track
2. Create track.tscn, load in main
3. Track as child node of Main

Decision: **Option 1** (replace ground) - simplest for single track

</code_context>

<specifics>
## Specific Ideas

**Track design priorities:**
- Drift-optimized: Turns encourage tier 2-3 drifts
- Flow: Straights connect turns naturally
- Visual clarity: Track boundaries obvious
- Testing: Validates all Phase 1-3 mechanics

**Example turn sequence:**
1. Start/finish straight (200 units)
2. Wide sweeper right (test tier 1 drift)
3. Chicane section (test quick directional changes)
4. Long straight (test boost chaining)
5. Hairpin left (test tier 3 drift)
6. Medium sweeper right (test tier 2)
7. Jump ramp (test air physics)
8. Final straight back to start

</specifics>

<deferred>
## Deferred Ideas

**Not in Phase 4 scope:**
- Multiple tracks → Phase 11: Additional Tracks
- Track selection UI → Phase 11
- Lap system logic → Phase 5: Lap & Race System
- Lap timer/display → Phase 6: Race UI
- Track decorations/theming → Phase 12: Polish
- Dynamic track elements (moving platforms) → v2 feature
- Track editor → v2 feature

**Noted for future phases:**
- Phase 5 will use checkpoint system for lap validation
- Phase 11 will replicate track structure for variety
- Phase 12 may optimize mesh further

</deferred>

---

*Phase: 04-first-race-track*
*Context gathered: 2026-03-22 (Auto-mode: Standard track design)*
*Reference: Mario Kart / Crash Team Racing track conventions*
