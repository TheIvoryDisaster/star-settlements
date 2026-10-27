# Feasibility experiments and go/no-go gates

This is a prioritized research backlog. A tested feature requires exact Starfield build, platform, reproducible test steps and observed outcome; document failure too.

## Spike 0 — toolchain bootstrap (blocker)

- On the existing Windows setup (Steam Creation Kit + PC Game Pass Starfield), use the Creation Kit's documented Microsoft Store setup procedure as needed. Load `Starfield.esm`, save a minimal plugin, compile `SCS_CompileSmokeTest.psc` via `scripts/Invoke-PapyrusCompile.ps1`, and test on a disposable Game Pass save.
- Verify that the resulting normal ESM/Papyrus Creation loads and executes on Game Pass using a documented installation method. Keep Steam runtime and Xbox console compatibility as separate verification tracks. **Do not require SFSE.**
- **Pass:** CK start, master load, plugin save, Papyrus compile, and observable in-game execution on PC Game Pass; save exact version and diagnostic evidence.
- **Stop:** CK cannot launch or binary/toolchain version mismatch.

## Spike 1 — workshop object lifetime

- Create a distinct buildable test marker in outpost menu.
- Log `OnWorkshopObjectPlaced/Moved/Removed` and `GetWorkshop()` on the relevant refs.
- Test on fresh/old outposts, relog, move/delete, travel, save/load, and multiple workshops.
- **Pass:** correct unique registry entries and no orphaned/duplicate object entries after 20 repeated edits.

## Spike 2 — NPC routing and facilities

- One generic colonist works at a player-placeable console, visits a bed and moves between two navigation targets.
- Test indoor/outdoor, doors, stairs, clutter, displaced construction, arrival after cell reload.
- **Pass:** reliable reachable interactions; no persistent NPC stuck state in repeat scenarios.
- **Fail:** arbitrary player-built interiors cannot be navigated reliably; narrow plot design to known-safe components and avoid remote navigation assertions.

## Spike 3 — persistence and Game Pass portable load

- Create small registry and one named actor, record relationships/assignments, save/restart, unload/reload, wait 7 and 30 in-game days, enter New Game Plus on disposable save.
- **Pass:** correct restoration with defined NG+ reset policy; never produce duplicate actors, duplicate resource deductions or malformed save dependency.
- **Stop:** unresolved save corruption, leaks, escalating scripts or repeated spawning.

## Spike 4 — unloaded resource simulation

- Add 1 farm, 1 workshop, 1 shared stockpile and 1 consumer, test 1/5/30 days advanced by sleep/travel, then physically return.
- Compare ledger to actual engine inventory and link results.
- **Pass:** deterministic, recoverable totals; no negative inventory, duplicated output or inconsistent cargo state.

## Spike 5 — defensive assignment

- Guard station and patrol points, temporary combat kit with saved original items.
- Trigger controlled raid; ensure faction hostility, combat, revive/reload, armament restore, no children in combat roles.
- **Pass:** 10 consecutive encounters without permanent equipment loss or assignment leaks.

## Spike 6 — level-up plot without navmesh damage

- Build Level 1 plot; advance to Levels 2 and 3 through triggered conditions; go back to L1 for rollback.
- Move/scrap plot at each level; check owned object cleanup, power/links, navigation, lights, collision.
- **Pass:** visible upgrades with unchanged safe navigable footprint, no orphaned refs, crashes or stuck actors.

## Spike 7 — load/performance envelope

- See PERFORMANCE.md. Exceeding agreed thresholds returns system to architecture review, NOT immediately to native injection.

## Priority

0 → 1 → 2 → 3 → 4 → 6 → 5 → 7, with performance sampling from the first actor test onward.
