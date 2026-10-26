# Contributing

1. Choose a tracked spike or feature issue, and create a branch such as `spike/workshop-events` or `feature/recruitment-logic`.
2. Note platform/build tested (Steam / Game Pass) and exact game version when submitting engine behavior results.
3. Distinguish verified Starfield APIs and observed behavior from FO4-inherited documentation and hypotheses.
4. Describe a reproducible manual test, expected vs actual, logs, save-state and FPS/frame-time measurements if relevant.
5. Keep binary plugin editing serialized. One owner changes each `.esm` at a time; plugin records cannot be meaningfully merged as text.
6. Never commit Bethesda extracted assets, game executable, generated binaries, proprietary mods, credentials, or third-party models without redistribution permission.
7. Pull requests must include a rollback/safe save plan for persistence-sensitive changes.
