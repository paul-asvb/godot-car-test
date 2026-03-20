# Pitfalls Research

**Domain:** Arcade Kart Racing (Mario Kart-style)
**Researched:** 2026-03-20
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Drift Feel Takes Forever to Tune

**What goes wrong:**
Drift mechanics feel too slippery, too sticky, or unresponsive. Players can't tell when they're drifting. Team spends weeks tweaking constants without finding "the sweet spot."

**Why it happens:**
Too many variables (turn rate during drift, speed retention, boost calculation) with non-linear interactions. No reference implementation to compare against.

**How to avoid:**
1. Start with reference values from successful Godot kart projects
2. Implement visual feedback (sparks) FIRST before tuning feel
3. Record gameplay video of Mario Kart for side-by-side comparison
4. Limit tuning to 3-4 key constants (drift_turn_speed, drift_friction, boost_multiplier)
5. Get external playtesters early - developers go "nose blind" to feel

**Warning signs:**
- Changing constants daily without clear direction
- Players saying "it feels weird" but can't explain why
- No visual feedback making state transitions invisible

**Phase to address:**
Phase 1 (Arcade Physics + Drift) - Build with reference values, test extensively before moving on

---

### Pitfall 2: Splitscreen Performance Tanks

**What goes wrong:**
Game runs at 60 FPS with 1-2 players, drops to 15 FPS with 4 players in web build. Unplayable.

**Why it happens:**
Each SubViewport renders the full scene - 4 players = 4x render cost. Particle effects, lighting, and draw calls multiply. WebAssembly has limited performance compared to native.

**How to avoid:**
1. Profile with 4 players FROM DAY ONE (don't wait until end)
2. Design track with performance in mind (low poly, simple lighting)
3. Reduce SubViewport resolution (720p per player, not 1080p)
4. Limit particles per effect (max 50-100 particles)
5. Use SimpleMaterial3D instead of StandardMaterial3D where possible
6. Consider dynamic quality scaling based on player count

**Warning signs:**
- FPS drop when adding 3rd/4th player
- Browser tab eating >2GB RAM
- Particle effects causing frame spikes

**Phase to address:**
Phase 4 (Splitscreen 2-4 Players) - Performance testing must be part of implementation, not afterthought

---

### Pitfall 3: Checkpoint System Allows Shortcuts

**What goes wrong:**
Players discover they can skip sections of track by cutting corners or going backwards through checkpoints. Lap counting breaks.

**Why it happens:**
Checkpoints placed too far apart, or validation doesn't check order, or finish line counts laps regardless of checkpoint sequence.

**How to avoid:**
1. Place checkpoints every major turn (8-12 per lap minimum)
2. Validate checkpoint sequence - must hit N before N+1
3. Don't count lap unless ALL checkpoints hit in order
4. Add invisible walls or slow-down zones in obvious shortcut areas
5. Playtest specifically for shortcut hunting

**Warning signs:**
- Players completing laps in 5 seconds
- Lap counter incrementing without visible progress
- Checkpoint "N" hit before checkpoint "N-1"

**Phase to address:**
Phase 3 (Track + Lap System) - Checkpoint placement and validation logic must be robust

---

### Pitfall 4: Input Conflicts in Splitscreen

**What goes wrong:**
Player 2 pressing "accelerate" also makes Player 1 accelerate. Or keyboard player's input affects gamepad player. Controls feel broken.

**Why it happens:**
Using Input.is_action_pressed() without player ID routing. Godot's input actions are global by default, not per-player.

**How to avoid:**
1. Use Input.get_joy_axis(device_id, axis) for gamepad-specific input
2. Create input wrapper that routes by player_id
3. Don't use global input actions in kart scripts - pass input from SplitscreenManager
4. Test with keyboard + gamepad simultaneously early
5. Assign specific device IDs to each player at race start

**Warning signs:**
- Multiple karts respond to same button press
- Gamepad input affects keyboard-controlled kart
- Can't distinguish Player 1 vs Player 2 input

**Phase to address:**
Phase 4 (Splitscreen 2-4 Players) - Input routing architecture critical from start

---

### Pitfall 5: Camera Motion Sickness

**What goes wrong:**
Players feel nauseous after 5 minutes of gameplay. Camera jerks around, rotates too fast, or snaps to kart position.

**Why it happens:**
No camera smoothing, or camera rotates with kart instantly, or FOV changes are too aggressive. High-frequency movement is nauseating.

**How to avoid:**
1. Lerp camera position and rotation (don't snap)
2. Use separate camera target slightly ahead of kart (not exact kart position)
3. Limit FOV changes (65° to 75° max range, smooth transitions)
4. Add slight drift offset (camera lags behind during turns)
5. Test with someone prone to motion sickness

**Warning signs:**
- Testers say "I feel dizzy"
- Camera rotates instantly when kart turns
- Camera clips through track or obstacles

**Phase to address:**
Phase 2 (Visual Feedback) - Camera smoothing should be implemented with basic movement

---

### Pitfall 6: Boost Tier Thresholds Feel Arbitrary

**What goes wrong:**
Players can't tell what tier they're in, or tier 3 takes forever to reach, or tiers trigger inconsistently. Boost system feels unrewarding.

**Why it happens:**
Threshold timing not playtested, or visual feedback doesn't match internal state, or timer doesn't account for player losing drift.

**How to avoid:**
1. Use clear time thresholds (e.g., 0.5s = blue, 1.5s = orange, 3.0s = pink)
2. Make tier changes obvious with sound + particle color change
3. Reset drift timer if player stops turning or releases brake
4. Show drift timer debug overlay during development
5. Playtest: does tier 3 feel achievable but not trivial?

**Warning signs:**
- Players asking "did I get boost?"
- Tier 3 never reached in normal gameplay
- Boost feels random instead of skill-based

**Phase to address:**
Phase 1 (Arcade Physics + Drift) - Tier thresholds must be validated through play

---

### Pitfall 7: Power-Up Balance Nightmare

**What goes wrong:**
One item is overpowered (always wins), or items don't interact well, or testing every combination takes weeks. Balance patch after balance patch.

**Why it happens:**
Too many items with complex interactions. Each new item multiplies testing matrix (N² interactions).

**How to avoid:**
1. Start with 3-4 core items maximum (speed boost, projectile, defense, trap)
2. Keep item effects simple and predictable
3. Test items individually before testing interactions
4. Accept imperfect balance initially - fun > perfect balance
5. Defer additional items until core set is solid

**Warning signs:**
- One item never used (underpowered)
- One item always picked (overpowered)
- Items interact in confusing ways
- Balance discussions dominate development time

**Phase to address:**
Phase 5 (Power-up System) - Strict scope limit on item count, playtest continuously

---

### Pitfall 8: Web Build Size Bloat

**What goes wrong:**
Web build takes 5 minutes to load, or is 200MB download. Players abandon before game loads.

**Why it happens:**
Large 3D models, uncompressed audio, texture resolution too high, including unused engine modules.

**How to avoid:**
1. Use procedural meshes (already doing - keep this!)
2. Compress audio (OGG Vorbis, not WAV)
3. Limit texture resolution (1024x1024 max)
4. Disable unused Godot modules in export settings
5. Test loading time on slow connection (throttle to 3G speed)
6. Stream audio instead of preloading all sounds

**Warning signs:**
- Build size > 50MB
- Load time > 30 seconds on broadband
- Browser shows "Page Unresponsive" during load

**Phase to address:**
All phases - Monitor build size continuously, optimize before 50MB threshold

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcoded track checkpoints in script | Fast to implement | Can't reuse checkpoint system, painful track editing | Never - use scene resources |
| Global state for race data | Easy to access anywhere | Can't reset state, multiplayer impossible later | Only for true singletons (RaceManager) |
| Magic numbers in physics constants | Quick tuning | Hard to find/change, no documentation | MVP only - extract to constants ASAP |
| Single race_scene.gd with all logic | Fewer files | Unmaintainable beyond 500 lines | Never - separate from start |
| Skipping performance profiling | Faster development | Performance crisis at launch | Never for splitscreen features |

## Integration Gotchas

Common mistakes when connecting to Godot systems.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| **SubViewport setup** | Forgetting to enable own_world_3d | Set viewport.own_world_3d = true for independent rendering |
| **CharacterBody3D** | Using Godot 3.x move_and_slide API | Godot 4.x changed API - no parameters, returns bool |
| **Input remapping** | Assuming joypad 0 is Player 1 | Explicitly assign device IDs, handle hotplugging |
| **AudioStreamPlayer3D** | Not setting max_distance | Audio audible across entire track - set ~20 units max |
| **GPUParticles3D** | Using one_shot without reemitting | Call restart() to trigger one-shot particles |

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| **Too many GPUParticles3D** | Frame drops when multiple karts drift | Limit 2-3 particle emitters per kart, reduce particle count | 4-player splitscreen |
| **High-poly collision meshes** | Physics stutter, frame spikes | Use simple shapes (capsule/box), not mesh collision | Multiple karts + items |
| **Unoptimized track geometry** | Low FPS in splitscreen | Keep track under 10k triangles, use LOD | 4 viewports rendering track |
| **3D audio for every sound** | Audio clicks, dropouts | Limit concurrent 3D audio streams to 8-10 | 4 karts with items/effects |
| **No draw distance culling** | Rendering entire track always | Use VisibilityNotifier3D or manual culling | Longer tracks, splitscreen |

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| **Client-side position validation** | Cheating in "online" version (if added later) | Accept for local-only, architect for server validation if networking added |
| **Unvalidated checkpoint progression** | Exploit shortcuts to win | Enforce checkpoint sequence server-side (if networked) |
| **Trusting browser timers** | Time manipulation in time trials | Accept for local play, use server time for leaderboards |

*Note: Current scope (local-only) has minimal security concerns. These apply if online features added.*

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| **No visual drift feedback** | Players don't know if drift is working | Spark particles + UI indicator BEFORE tuning physics |
| **Unclear boost activation** | Players don't know when to release drift | Obvious sound + visual cue + brief slowdown effect on release |
| **Confusing position display** | Players don't know if they're winning | Large, always-visible position number (1st/2nd/3rd/4th) |
| **No starting countdown** | Races feel abrupt, unfair starts | 3-2-1-GO countdown with visual + audio |
| **Instant race end** | Anticlimactic finish | Results screen with race replay or final positions |
| **No audio feedback** | Game feels flat and lifeless | Engine sound minimum, drift/boost sounds critical |

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **Drift mechanic:** Often missing visual feedback tier indication — verify sparks change color
- [ ] **Lap system:** Often missing shortcut prevention — verify checkpoint sequence validation
- [ ] **Splitscreen:** Often missing per-player HUD — verify each player sees their own lap/position
- [ ] **Starting countdown:** Often missing input blocking during countdown — verify karts can't move until GO
- [ ] **Results screen:** Often missing replay/restart option — verify players can race again
- [ ] **Audio:** Often missing pitch variation — verify engine sound changes with speed
- [ ] **Camera:** Often missing smoothing — verify camera doesn't snap to kart position
- [ ] **Items:** Often missing visual feedback — verify player knows what item they have

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Drift feel issues | MEDIUM | Record reference gameplay video, implement metrics logging, A/B test constants with playtesters |
| Splitscreen performance | HIGH | Profile with Godot profiler, identify bottleneck, reduce quality (viewport res, particles, draw distance) |
| Checkpoint exploits | LOW | Add more checkpoints, implement sequence validation, add invisible collision barriers |
| Input conflicts | MEDIUM | Refactor input system to route by player_id, test with multiple devices |
| Camera motion sickness | LOW | Add lerp smoothing, reduce FOV changes, add camera lag during turns |
| Boost tier feel | LOW | Adjust threshold constants, improve visual feedback, add debug timer display |
| Power-up balance | MEDIUM | Remove overpowered items temporarily, simplify effects, reduce item count |
| Web build bloat | MEDIUM | Profile build size, compress audio, reduce texture resolution, disable unused modules |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Drift feel issues | Phase 1 | Extended playtest session, record gameplay vs. reference |
| Splitscreen performance | Phase 4 | FPS profiling with 4 players, min 30 FPS target |
| Checkpoint exploits | Phase 3 | Shortcut hunting playtest, automated checkpoint validation tests |
| Input conflicts | Phase 4 | Multi-device input test (keyboard + 3 gamepads simultaneously) |
| Camera motion sickness | Phase 2 | Playtest with motion-sensitive person, check for smooth movement |
| Boost tier feel | Phase 1 | Playtest can reach all 3 tiers consistently in normal racing |
| Power-up balance | Phase 5 | Win rate analysis across items, player preference survey |
| Web build bloat | Continuous | Build size < 50MB, load time < 30s on broadband |

## Sources

- Godot splitscreen performance discussions (forum posts, Discord)
- Godot arcade racing open-source project post-mortems
- Mario Kart game feel analysis and GDC talks
- Web build optimization best practices for Godot 4.x
- Existing codebase concerns audit (.planning/codebase/CONCERNS.md)

---
*Pitfalls research for: Arcade Kart Racing*
*Researched: 2026-03-20*
