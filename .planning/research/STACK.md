# Stack Research

**Domain:** Arcade Kart Racing (Mario Kart-style)
**Researched:** 2026-03-20
**Confidence:** HIGH

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| **Godot Engine** | 4.5+ | Game engine | Already in use; excellent for 3D arcade games, built-in physics, strong web export support |
| **GDScript** | 4.x | Game logic | Native Godot language, optimal performance for game code, simpler than C# for arcade mechanics |
| **CharacterBody3D** | Built-in | Kart physics controller | Better for arcade handling than RigidBody3D - direct control over movement vs. physics simulation |
| **GPUParticles3D** | Built-in | Visual effects (drift sparks, boost flames) | Hardware-accelerated particle system for smooth effects in splitscreen |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| **Godot Jolt Physics** | 0.12+ (optional) | Enhanced 3D physics | Only if keeping some physics-based collision; NOT needed for pure arcade CharacterBody3D approach |
| **Post-processing shaders** | Custom | Speed lines, motion blur | For visual polish - implement as custom shader materials |
| **Input remapping plugins** | N/A | Controller support | Godot 4.x has built-in input remapping - no plugin needed |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| **Godot Editor 4.5** | Scene/script editing | Already in use - no changes |
| **Just (task runner)** | Build automation | Already in use - keep existing justfile |
| **GitHub Actions** | CI/CD for web build | Already configured - keep existing workflow |
| **Browser DevTools** | Web build debugging | F12 console for WebAssembly debugging |

## Changes from Current Stack

### Keep (No Changes)
- ✓ Godot 4.5 engine
- ✓ GDScript language
- ✓ Forward Plus renderer
- ✓ Web export to GitHub Pages
- ✓ Just task runner
- ✓ GitHub Actions CI/CD

### Replace
- ❌ **RigidBody3D physics** → **CharacterBody3D kinematic** 
  - Reason: Arcade feel requires direct control, not physics simulation
  - Migration: Rewrite car.gd to use move_and_slide() instead of apply_force()
  
- ❌ **Raycast suspension system** → **Ground-hugging arcade movement**
  - Reason: Mario Kart doesn't simulate suspension, karts stick to track
  - Simpler: No spring-damper math, just align to track normal

### Add New
- **MultiMeshInstance3D** for tire marks/skid trails
  - Efficient rendering of many trail segments
  
- **GPUParticles3D** nodes for visual effects
  - Drift sparks (color-changing based on boost tier)
  - Boost flame trails
  
- **SubViewport** nodes for splitscreen
  - One viewport per player (2-4 viewports total)
  - Performance: Keep viewport resolution reasonable for web
  
- **AudioStreamPlayer3D** for positional audio
  - Engine sounds, drift sounds, item effects

## Installation

No package installation needed - all features are built into Godot 4.5.

**Project structure additions:**
```bash
# Create new directories for racing systems
mkdir -p systems/kart_controller
mkdir -p systems/race_manager
mkdir -p systems/powerup_system
mkdir -p ui/race_hud
mkdir -p tracks/
mkdir -p effects/particles
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| CharacterBody3D | RigidBody3D | If you want semi-realistic physics (not for Mario Kart feel) |
| GPUParticles3D | CPUParticles3D | If targeting very old hardware (web should use GPU) |
| GDScript | C# | If team is already C#-focused (not worth switching for this project) |
| Built-in multiplayer | Netcode plugins | Only for online multiplayer (out of scope) |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| **VehicleBody3D** | Too realistic, poor for arcade feel - designed for racing sims | CharacterBody3D with custom arcade controller |
| **Jolt Physics** | Unnecessary overhead for non-physics-based arcade movement | Built-in Godot collision detection |
| **Heavy 3D models** | Web build size/performance constraint | Procedural meshes + simple textures (already doing this) |
| **Third-party asset packs** | Licensing complexity, load time overhead | Procedural generation or custom simple assets |
| **Real-time GI** | Performance killer in splitscreen web builds | Baked lightmaps or simple lighting |

## Stack Patterns by Variant

**If prioritizing web performance:**
- Use low-poly procedural meshes (already doing)
- Limit particle count per effect (max 50-100 particles per emitter)
- Use SimpleMaterial3D over StandardMaterial3D where possible
- Keep SubViewport resolution at 720p or lower per player

**If adding desktop builds:**
- Can increase particle counts
- Can use higher resolution textures
- Can enable more advanced rendering features

**If targeting 4-player splitscreen:**
- CRITICAL: Test performance early with 4 viewports active
- May need to reduce draw distance
- May need to simplify particle effects
- Consider dynamic quality adjustment based on player count

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| Godot 4.5 | WebAssembly export | SharedArrayBuffer requires HTTPS + headers (GitHub Pages compatible) |
| Godot 4.5 | Gamepad API | Web gamepad support works in Chrome/Firefox/Edge (Safari limited) |
| GDScript 4.x | CharacterBody3D | move_and_slide() API changed from Godot 3.x - use 4.x syntax |

## Performance Considerations (Web Build)

**Critical for splitscreen web:**
- Each viewport adds full render cost
- 4 players = 4x render calls
- Target 60 FPS with 2 players minimum
- Accept 30 FPS with 4 players if necessary

**Optimization priorities:**
1. Simple collision shapes (capsules/boxes, not complex meshes)
2. Particle count limits
3. Draw distance culling
4. LOD for distant objects (if many track decorations)
5. Audio stream compression

## Sources

- Godot 4.5 official documentation (CharacterBody3D, SubViewport, GPUParticles3D)
- Existing codebase analysis (.planning/codebase/STACK.md)
- Godot arcade racing tutorials and open-source kart projects
- Mario Kart game design analysis (arcade physics vs. simulation)
- WebAssembly performance testing with Godot 4.x

---
*Stack research for: Arcade Kart Racing*
*Researched: 2026-03-20*
