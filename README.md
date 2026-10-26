# Starfield Colony Systems (SCS)

> Status: feasibility / engineering-spikes only. **This repository contains no playable mod, compiled Papyrus scripts, Starfield plugin, or Bethesda-owned assets.**

A proposed Sim Settlements-inspired framework for **Starfield** outposts: recruit colonists; operate homes, jobs and needs; organize defense and households; support quests, plot upgrades and inter-outpost logistics.

## Current decision (2026-10-26)

- **Core:** official Starfield Creation Kit + base-game Papyrus and records, aiming at portable Creations/Game Pass/Steam/Xbox support where the final feature set permits.
- **Optional:** an isolated experimental SFSE/native adapter for Steam only, *if a measured issue cannot be solved with the core*.
- **Blocking constraint:** Bethesda's support article says the Creation Kit does not launch without Starfield owned **and installed on Steam**. The user's current Game Pass copy can run compatible Creations, but cannot serve as the documented CK authoring setup. Official SFSE likewise does **not** support Game Pass.
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

Before implementing a colony system, obtain access to a **Steam-owned and installed** Starfield development environment. Prove: one buildable marker receives placement/removal events; one NPC can navigate to a designated work target; one piece of state survives save/load and outpost unload/reload; a non-navigable plot changes visual level safely; and unloaded inventory/resource calculations do not double-charge.

## Local repository setup

```powershell
# Unzip this starter, open PowerShell in its directory, then:
git init -b main
git add .
git commit -m "docs: initial feasibility and architecture"

# Optional with GitHub CLI (after gh auth login):
gh repo create starfield-colony-systems --private --source . --remote origin --push
```

Or create an empty GitHub repository manually, then `git remote add origin <YOUR_REPO_URL>` followed by `git push -u origin main`.

`python tools/verify_repo.py` runs basic repository integrity checks. It does **not** compile Papyrus or test Starfield in-game.

## Licensing and IP

Repository docs and original future source are currently MIT-licensed (see LICENSE). Third-party contributed assets may have separate permitted use or redistribution terms. Do not upload Bethesda game data, extracted assets, tools, authentication tokens, or other mods without permission. Hi3D outputs require checking the service's current license and the source assets used.
