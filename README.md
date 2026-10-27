# Starfield Colony Systems (SCS)

> Status: feasibility / engineering-spikes only. **This repository contains no playable mod, compiled Papyrus scripts, Starfield plugin, or Bethesda-owned assets.**

A proposed Sim Settlements-inspired framework for **Starfield** outposts: recruit colonists; operate homes, jobs and needs; organize defense and households; support quests, plot upgrades and inter-outpost logistics.

## Current decision (2026-10-26)

- **Core:** official Starfield Creation Kit + base-game Papyrus and records, aiming at portable Creations/Game Pass/Steam/Xbox support where the final feature set permits.
- **Optional:** an isolated experimental SFSE/native adapter for Steam only, *if a measured issue cannot be solved with the core*.
- **Development target:** Steam-installed Creation Kit with PC Game Pass Starfield. The CK *Getting Started* materials provide a Microsoft Store setup path using `ExportEditorDirToTarget.bat`; test actual editor/compiler/runtime behavior rather than preemptively requiring a Steam game purchase. Official SFSE compatibility remains platform-limited, so the Xbox-compatible core cannot require it.
- **Design pattern:** persistent per-outpost colony data, event-driven object tracking, virtual/offline production, and bounded loaded-area AI. No universal high-frequency NPC polling.
- **Main unknown:** plot upgrades vs. navigability, AI behavior inside movable habs, unloaded outpost simulation, save-game behavior, and performance at 20+ colonists.

## Repository guide

- [Feasibility and confirmed API surface](docs/FEASIBILITY.md)
- [Proposed architecture](docs/ARCHITECTURE.md)
- [Critical feasibility spikes and go/no-go criteria](docs/ENGINE_SPIKES.md)
- [Performance and stability test plan](docs/PERFORMANCE.md)
- [Workstation/Creation Kit setup](docs/ENVIRONMENT.md)
- [Product roadmap](docs/ROADMAP.md)
- [Design decisions](docs/decisions/0001-ck-core-optional-sfse.md)
- [Sources](docs/SOURCES.md)

## Early milestone

Before implementing a colony system, complete [M0 toolchain validation](scripts/runbooks/M0-TOOLCHAIN.md), including the [Papyrus compiler smoke test](scripts/Invoke-PapyrusCompile.ps1). Prove: one buildable marker receives placement/removal events; one NPC can navigate to a designated work target; one piece of state survives save/load and outpost unload/reload; a non-navigable plot changes visual level safely; and unloaded inventory/resource calculations do not double-charge.

## Development runbooks

- `python tools/verify_repo.py`: repository hygiene (no actual game tests).
- `scripts/Invoke-M0Toolchain.ps1`: local executable/version inventory and structured manual test evidence.
- `scripts/Invoke-PapyrusCompile.ps1`: compile `src/papyrus/SCS_CompileSmokeTest.psc` with the Starfield CK compiler to gitignored `out/papyrus`.
- `scripts/runbooks/M0-TOOLCHAIN.md`: M0 operator procedure and exit gates.

Compiler output alone does not establish successful in-game execution or Xbox deployment.

## Licensing and IP

Repository docs and original future source are currently MIT-licensed (see LICENSE). Third-party contributed assets may have separate permitted use or redistribution terms. Do not upload Bethesda game data, extracted assets, tools, authentication tokens, or other mods without permission. Hi3D outputs require checking the service's current license and the source assets used.
