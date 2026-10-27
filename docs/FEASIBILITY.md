# Feasibility report — 2026-10-26

## Outcome

**Conditional GO** for prototype/research; **NO GO** for a production-scale colony feature set until early tests validate the engine assumptions. No in-game benchmarks have been performed.

## Immediate external constraints

- Steam distributes the Starfield Creation Kit. Although [Bethesda support](https://help.bethesda.net/app/answers/detail/a_id/73814/) describes a Steam Starfield requirement, the Starfield CK *Getting Started* documentation also includes a **Microsoft Store installation workflow** using `ExportEditorDirToTarget.bat` ([archived CK setup PDF](https://files.catbox.moe/4xycfq.pdf)). We will validate the actual CK/Game Pass setup before deciding whether a second runtime is necessary.
- Official SFSE runtime supports Steam Starfield only, *not* Microsoft Store/Game Pass. [SFSE README](https://github.com/ianpatt/sfse) / [SFSE site](https://sfse.silverlock.org/).
- The user's Steam CK + PC Game Pass environment is our initial authoring/runtime test target. Script compilation, plugin load, and Xbox distribution are distinct checks and must be proven independently.

## Starfield base-game Papyrus surface (presence verified, runtime behavior not tested)

- `ObjectReference.OnWorkshopObjectPlaced`, `OnWorkshopObjectMoved`, `OnWorkshopObjectRemoved`: detect player outpost build edits.
- `ObjectReference.GetWorkshop`: identify owning workshop from a reference.
- `ObjectReference.GetWorkshopOwnedObjects`: discover actor-owned workshop references; verify actual semantics in Starfield before using it for beds/jobs.
- `ObjectReference.GetWorkshopResourceObjects`: enumerate workshop production objects; not a general inventory query.
- `ObjectReference.CanProduceForWorkshop`: docs say invalid in unloaded cells; never call as authoritative remote production state.
- `ObjectReference.OnWorkshopCargoLinkChanged`: detect cargo link target changes; does not guarantee inventory flow APIs.
- `ObjectReference.OnCrewAssigned`, `OnCrewDismissed`: crew/assignment event hooks.
- `Game.AddToAvailableCrew`: register eligible NPC in unassigned player crew list, not automatic proof that the desired colonist limit is achievable.

Source: [Starfield Papyrus Index ObjectReference](https://papyrus.bellcube.dev/starfield/script/objectreference/), [Game.AddToAvailableCrew](https://papyrus.bellcube.dev/starfield/script/game/function/addtoavailablecrew/). Some page explanations are inherited from Fallout 4; verify with compiled scripts and game events.

## Feature feasibility by subsystem

| Area | Assessment | Candidate path | Critical unknown |
| --- | --- | --- | --- |
| Attract colonists based on stats/outpost | High | Beacon + Papyrus timers + recruit actor data; Bard's precedent | NPC count/aliases/lifetime, cross-cell persistence |
| Skills and employment | Medium-high | Role registry, interactable facilities, optional AI packages | reliable scheduling at arbitrary user-built work sites |
| Needs, food, inventory | Medium-high | aggregate resource accounting + periodic updates | workshop-linked container ownership, persistence, double-spend |
| Armed guards, raid support | Medium | combat-ready NPC, guard idle packages, guard posts | combat packages/cover, safe equipment restoration |
| Families, housing, children | Medium | logical household registry + bed ownership; authored child actors | relationship/animation/dialogue limits; appropriate child protection |
| Unique quests/NPCs | High | Creation Kit quests/dialogue/aliases | complex state integration with generated residents |
| Buildings/Hi3D assets | High | Blender/NIF/mesh/material/collision pipeline | navmesh; collision; redistributed assets; performance |
| Sim Settlements plots and levels | Medium-risk / proof needed | fixed-footprint plot with cosmetic prefabs swapped | AI navmesh when upgraded, workshop ownership, spawned ref cleanup |
| Cargo + supply networks | Medium | existing cargo links + logical network ledger | inventory transfers, unloaded resource consistency |
| Native engine alterations | Platform-limited | isolated SFSE bridge for Steam only | Game Pass unsupported; update breakage; hook safety |

## Relevant precedents, *not* proof of our own integration

1. [Bard's Outpost Recruitment Beacon](https://creations.bethesda.net/en/starfield/details/6d04f1a5-e426-4817-a7f7-1529f9bd6d83/Bard__39_s_Outpost_Recruitment_Beacon): named colonists, families, perks, conversation and sandbox/guard patrol behaviors, 10–20 selectable cap.
2. [Frontier Logistics — Outpost Industry](https://www.nexusmods.com/starfield/mods/18363): food, medical, chem fabricators and outpost production chain expansion (October 2026).
3. [Adjusted Outpost Limits](https://www.nexusmods.com/starfield/mods/9741): alters crew, turret, cargo link and other limits; author flags parts as untested. Raising configurable limits does NOT prove performance safety.
4. [Sim Settlements plot upgrade rules](https://simsettlements.com/web/wiki/index.php?title=Upgrades): *design inspiration only*, not reusable Starfield code or granted rights.

## Technical strategy

Prefer original engine data types wherever reliable. Never model individual outpost residents with high frequency simulation while a different planet is loaded. Use the event registry + scheduled batch processing. Render/activate NPC behaviors only where physically needed. Do not mutate standard cargo links until their accounting model is measured.

## Decisions blocked on early spikes

See ENGINE_SPIKES.md. High-level feasibility is not the same as committing to implementation at scale.
