# Feature Research

**Domain:** Arcade Kart Racing (Mario Kart-style)
**Researched:** 2026-03-20
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Responsive steering** | Core control - must feel tight and immediate | MEDIUM | CharacterBody3D rotation/movement logic |
| **Drifting mechanic** | Signature Mario Kart feature, essential for arcade kart feel | MEDIUM | State machine (normal/drift/boost), input buffering |
| **Boost from drifting** | Reward for skilled drifting, core gameplay loop | MEDIUM | Timer tracking drift duration, tier thresholds |
| **Visual drift feedback** | Players need to see boost tier progress | LOW | Particle effects (blue→orange→pink sparks) |
| **Lap tracking** | Must know which lap you're on | LOW | Checkpoint system with lap counter |
| **Position display** | Must know your race position (1st/2nd/etc.) | LOW | Sort players by checkpoint/distance |
| **Speed sensation** | Game must feel fast | MEDIUM | Camera FOV changes, speed lines, motion blur |
| **Collision with track/obstacles** | Can't drive through walls | LOW | StaticBody3D collision, already exists |
| **Proper race track** | Looping course with start/finish line | MEDIUM | Track design and checkpoint placement |
| **Lap timer** | Players want to know their time | LOW | Timer display in UI |

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Multi-tier drift boost (3 tiers)** | More skill expression than single-tier | LOW | Just threshold checks on drift timer |
| **Power-up items** | Adds unpredictability, "blue shell" moments | HIGH | Item system, projectile physics, player interactions |
| **Local splitscreen (2-4 players)** | Couch multiplayer differentiates from single-player racers | HIGH | SubViewport setup, per-player input, performance optimization |
| **Multiple tracks** | Replayability and variety | MEDIUM | Track design time, not technically complex |
| **Web-based** | No download, easy to share | N/A | Already planned |
| **Smooth camera follow** | Professional feel, reduces motion sickness | MEDIUM | Camera damping, drift offset, smoothing |
| **Tire marks/skid trails** | Visual feedback for drifting path | MEDIUM | MultiMeshInstance3D trail generation |
| **Audio feedback** | Engine pitch, drift sounds, boost sound | LOW | AudioStreamPlayer nodes, pitch shifting |
| **Starting countdown (3-2-1-GO)** | Professional race start experience | LOW | Timer + UI + input blocking |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| **AI opponents** | "Need something to race against" | Complex pathfinding, behavior tuning, not core to "fun with friends" goal | Focus on multiplayer polish; add ghost times later if needed |
| **Online multiplayer** | "I want to play with remote friends" | Networking complexity, latency compensation, server costs, security | Local multiplayer first; validate fun factor before networking investment |
| **Extensive item variety (10+ items)** | "More items = more fun" | Balance nightmare, testing complexity, development time | 3-4 core items (speed boost, projectile, defensive, trap) cover main interactions |
| **Vehicle customization** | "I want to customize my kart" | Asset creation burden, balance between cosmetic/performance | Single kart model; focus on gameplay feel over customization |
| **Large open-world track** | "Exploration would be cool" | Performance issues in web build, hard to design for racing flow | Focused looping tracks (1-2 minutes per lap) optimized for drifting |
| **Realistic physics** | "Current suspension is cool" | Conflicts with arcade feel, harder to control | Arcade ground-hugging movement; save realism for different game |
| **Story/campaign mode** | "Give it progression" | Scope explosion, not needed for party game | Quick race menu; focus on pick-up-and-play |
| **Track editor** | "Let users make tracks" | UI complexity, serialization, testing burden | Pre-built curated tracks ensure quality racing lines |

## Feature Dependencies

```
[Lap tracking]
    └──requires──> [Checkpoint system]
                       └──requires──> [Track with start/finish line]

[Position display]
    └──requires──> [Lap tracking]
    └──requires──> [Checkpoint system]

[Drift boost system]
    └──requires──> [Drift mechanic]

[Visual drift feedback (sparks)]
    └──requires──> [Drift mechanic]

[Power-up items]
    └──requires──> [Item pickup detection]
    └──requires──> [Per-player item state]
    
[Splitscreen multiplayer]
    └──requires──> [Per-player camera]
    └──requires──> [Per-player input]
    └──requires──> [Per-player HUD]
    └──enhances──> [Power-up items] (items are more fun in multiplayer)

[Multiple tracks] ──independent──> [All racing features]

[Tire marks] ──enhances──> [Drift mechanic] (visual feedback)

[Audio feedback] ──enhances──> [All mechanics] (immersion)
```

### Dependency Notes

- **Lap tracking requires checkpoint system:** Can't count laps without detecting crossing finish line in correct direction
- **Position display requires lap tracking:** Need to know who's ahead based on lap + checkpoint progress
- **Drift boost requires drift mechanic:** Obviously, but tier system can be added incrementally
- **Splitscreen multiplayer requires per-player systems:** Each player needs independent camera, input, HUD rendering
- **Power-ups enhance splitscreen:** Items are way more fun with friends; less valuable solo

## MVP Definition

### Launch With (v1)

Minimum viable product — what's needed to validate "fun with friends" concept.

- [ ] **Single track** — One well-designed looping track with varied turns
- [ ] **Arcade kart physics** — Responsive steering, acceleration, ground-hugging
- [ ] **Drift mechanic (brake + turn)** — Enter drift state, maintain through turn
- [ ] **Multi-tier drift boost (3 tiers)** — Blue→orange→pink spark colors, speed boost on release
- [ ] **Visual feedback** — Drift sparks, boost flames, speed lines
- [ ] **Lap system (3 laps)** — Checkpoint-based lap tracking, finish line detection
- [ ] **Race UI** — Current lap, race timer, position
- [ ] **Local 2-player splitscreen** — Horizontal or vertical split, per-player controls
- [ ] **Basic audio** — Engine sound, drift sound, boost sound
- [ ] **Starting countdown** — 3-2-1-GO before race starts
- [ ] **Results screen** — Final positions and times
- [ ] **Menu system** — Track selection, player count (1-2), start race

### Add After Validation (v1.x)

Features to add once core is fun and working.

- [ ] **4-player splitscreen** — Once 2-player is smooth, expand to 4
- [ ] **Power-up items (3-4 types)** — Add competitive chaos
- [ ] **Second track** — Variety once core mechanics proven
- [ ] **Third track** — More replayability
- [ ] **Tire mark trails** — Visual polish for drifting
- [ ] **Advanced audio** — Music, positional audio, more sound effects
- [ ] **Camera improvements** — Drift offset, dynamic FOV
- [ ] **Ghost times / leaderboards** — Competition without AI opponents

### Future Consideration (v2+)

Features to defer until product-market fit is established.

- [ ] **AI opponents** — Only if single-player validation shows demand
- [ ] **Online multiplayer** — Major scope increase, defer until local is polished
- [ ] **More tracks (5+)** — Once core tracks are perfected
- [ ] **Advanced items (7+ types)** — Balance complexity grows exponentially
- [ ] **Time trial mode** — Nice but not essential for party game
- [ ] **Replay system** — Interesting but heavy lift
- [ ] **Customization** — Defer unless user research shows strong demand

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Arcade kart physics | HIGH | MEDIUM | P1 |
| Drift mechanic | HIGH | MEDIUM | P1 |
| Multi-tier boost | HIGH | LOW | P1 |
| Visual feedback (sparks/flames) | HIGH | LOW | P1 |
| Lap tracking | HIGH | LOW | P1 |
| Race UI | HIGH | LOW | P1 |
| 2-player splitscreen | HIGH | MEDIUM | P1 |
| Starting countdown | MEDIUM | LOW | P1 |
| Basic audio | MEDIUM | LOW | P1 |
| Single track | HIGH | MEDIUM | P1 |
| 4-player splitscreen | MEDIUM | MEDIUM | P2 |
| Power-up items | HIGH | HIGH | P2 |
| Multiple tracks (2-3 total) | MEDIUM | MEDIUM | P2 |
| Tire mark trails | LOW | MEDIUM | P2 |
| Advanced camera | MEDIUM | MEDIUM | P2 |
| AI opponents | LOW | HIGH | P3 |
| Online multiplayer | HIGH | VERY HIGH | P3 |
| Track editor | LOW | VERY HIGH | P3 |

**Priority key:**
- P1: Must have for launch (v1.0)
- P2: Should have, add when possible (v1.x)
- P3: Nice to have, future consideration (v2+)

## Competitor Feature Analysis

| Feature | Mario Kart 8 | Crash Team Racing | Our Approach |
|---------|--------------|-------------------|--------------|
| Drifting | Analog stick angle, auto-drift option | Manual drift button | Brake + turn (intuitive, keyboard-friendly) |
| Boost tiers | 3 tiers (blue/orange/purple sparks) | 3 tiers + perfect boost | Same 3-tier system (blue/orange/pink) |
| Items | 15+ items, item roulette | 10+ items, similar variety | Start with 3-4 core items (speed, projectile, defense, trap) |
| Multiplayer | 4-player local, 12-player online | 4-player local, 8-player online | 2-4 player local only (web constraint) |
| Tracks | 48 tracks (new + retro) | 18 tracks | 2-3 tracks for v1 (quality over quantity) |
| Anti-gravity | Track walls/ceiling driving | No anti-gravity | No anti-gravity (complexity) |
| Gliding | Glider sections | No gliding | No gliding (focus on ground racing) |
| Underwater | Physics change underwater | No underwater | No underwater (scope) |
| Tricks/Stunts | Aerial tricks for boost | No tricks | No tricks (keep simple) |
| Character stats | Weight classes affect handling | Speed/Accel/Handling stats | Single balanced kart (no character differences) |
| Course design | Wide tracks, multiple paths | Tight technical tracks | Balanced - wide enough for 4 players, tight enough for drifting |

**Our differentiation:**
- Web-based (no download barrier)
- Simpler item system (easier to learn)
- Focused feature set (polish over breadth)
- Local multiplayer emphasis (party game)

## Sources

- Mario Kart 8 Deluxe gameplay analysis
- Crash Team Racing: Nitro-Fueled mechanics research
- Godot arcade racing open-source projects (GitHub)
- Existing codebase feature audit (.planning/PROJECT.md)
- Web build performance constraints analysis

---
*Feature research for: Arcade Kart Racing*
*Researched: 2026-03-20*
