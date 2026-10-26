# ADR 0001 — Portable CK/Papyrus core, optional SFSE bridge

- Date: 2026-10-26
- Status: Proposed; acceptance contingent on engine spikes

## Context

The desired mod includes native-style systems but the project's current runtime is Xbox Game Pass for PC. SFSE is Steam-only, and Creation Kit authoring officially requires a Steam-owned and installed Starfield game.

## Decision

Build the minimum useful simulation in base Starfield scripting/records first; keep the core free from SFSE dependencies. Research C++ only after evidence that native engine access is essential, and package it as an *optional* Steam adapter (never required by cross-platform core saves).

## Consequences

Pros: better compatibility with Game Pass and Xbox, fewer runtime update breakages, smaller QA surface.

Cons: reduced low-level introspection, possibly lower max physically active population, and some UX/AI features may require simplification.

## Alternatives

- SFSE-first all-in-one (rejected currently due to Game Pass incompatibility).
- Game Pass-only direct hooking without official support (rejected as a research starting point because of version/correctness burden).
- Purely cosmetic beacon mod (rejected as insufficient for Sim Settlements-style goal).
