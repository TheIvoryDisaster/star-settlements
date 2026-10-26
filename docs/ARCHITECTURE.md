# Candidate architecture (not yet implemented)

## Layers

1. **Discovery/Registry** — keyed by stable workshop identity; track authored/placed infrastructure and important resident refs; reconcile after loading or changes. Important: a ref's in-game identity must remain stable across save/load; don't invent record ID storage format until tested.
2. **Population Ledger** — resident ID, outpost, role, skill, traits, household, home assignment, needs, status. Some named/special NPCs may require persistent actual Actor refs; virtual background residents are a design option, not an engine guarantee.
3. **Simulation Scheduler** — coarse updates triggered by meaningful events and game-time progression; update on transitions without a loop for every resident. Idempotent transactions; cap offline catch-up; inventory reconciliation.
4. **Outpost Economy** — aggregate production and consumption with explicit inventories/permissions and debt-free accounting. Native cargo flow remains authoritative where possible.
5. **AI Presentation** — separate work/idle/guard/sleep packages for loaded cells; monitor pathfinding failure; reduced physical NPC count when necessary.
6. **Plot System** — fixed navigable footprint and staged cosmetic changes plus stat benefits; reversible upgrades must never strand actors or orphan references.
7. **Quest/Story** — scripted scenarios and unique settlers dependent on stable published interfaces, avoiding deep coupling to simulation timers.
8. **Integration adapters** — basic Papyrus first; optional SFSE/native Steam-only module later if genuinely needed.

## State consistency rules

- The colony ledger is authoritative only for new mod-specific data; do not pretend to replace all Starfield workshop inventory or engine state.
- Process resource changes as reconciled transactions. Check resource availability, reserve, deduct, then commit outcomes. If inventory APIs aren't safe unloaded, defer operations or model them explicitly and settle on load.
- Distinguish **simulated colonist** from **physical actor**. Do not duplicate actors when loading/outpost revisits occur.
- Preserve player-placed objects and inventory during upgrades, resets, and uninstall scenarios as far as engine permits.
- Version persistent data, implement migrations, design an opt-in recoverable reset path, and document safe uninstallation limitations.
- Limit per-frame and per-actor Papyrus logic. Prefer workshop and crew events, batched updates, and scheduled ticks.

## Rough event flow

`OnWorkshopObjectPlaced -> event adapter -> registry delta -> capabilities/household/job recompute -> delayed UI/status refresh`

`game time / outpost visit -> scheduler -> needs + industry + safety calculation -> resource reconciliation -> presentation updates (only if loaded)`

## Plot upgrades

Start with a **single fixed footprint** and 3 visual levels. Never assume adding/removing collision makes the navmesh update. Avoid changing door and walkway positions in v0.1. New architectural variants can graduate once navigation tests pass.

## Native extension boundary

The optional bridge may expose advanced diagnostics or narrowly scoped queries, but must not be required to load core plugin data or to keep saves valid on Game Pass/Xbox. SFSE requires Steam. Don't design required world state to depend on C++ hooks until a cross-platform replacement exists.
