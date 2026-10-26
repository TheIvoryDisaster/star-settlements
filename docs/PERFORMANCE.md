# Performance and save stability plan

## Core principle

No baseline measurements exist yet. **All numbers below are proposed test targets, not claims about Creation Engine limits.** Establish baseline with the exact PC and game version and use median/p95 comparison.

## Test matrix

| Scenario | Variants |
| --- | --- |
| Population | 0, 5, 10, 20, 40 physically active (40 is stress-only unless validated) |
| Outposts | 1 loaded; 5 and 15 persistent but unloaded |
| Plots | 0, 5, 20, 50 (mostly cosmetic static stages) |
| AI | idle, shift change, work actions, 10+ guards in raid |
| Game time | immediate, 7 days offline, 30 days offline |
| Save lifecycle | save/load, fast travel, quit/restart, revisit, scrap/build, NG+ disposable copy |

## Metrics

- FPS and p50/p95/p99 frame time (milliseconds) on the same representative location; GPU settings controlled.
- Game thread stalls or prolonged freezes; individual slow-frame captures where possible.
- Papyrus log errors, queued tasks or unusually long stacks if instrumentation is available.
- Save-file sizes and save/load duration compared to unmodded baseline on same playthrough.
- Number of instantiated AI references, active packages, failed pathing requests, orphaned refs.
- Resource accounting mismatch after load, storage transfer, and game-time catch-up.

## Proposed gates (to revise after baseline)

- No reproducible crashes, permanent AI softlocks, lost or duplicated resources, or bad saves.
- Target p95 frame-time regression < 3 ms at the recommended resident cap on test PC and chosen baseline scene.
- No unbounded growth in save size or script processing after repeated identical cycles.
- Cap configurable, default conservative: initially 10 active on-screen physical colonists; scale only after empirical tests. Do not confuse an actor count with all simulated residents.
- No continuous per-resident polling while the settlement is unloaded; batch bounded catch-up events.

## Test recording

Include Windows hardware (CPU/GPU/RAM), Starfield build/edition, CK version, mod commit hash, other mods enabled, GPU/display settings, test save origin, baseline + modded metrics, log snippet and expected vs actual behavior.

Do not claim a result passed without in-game evidence.
