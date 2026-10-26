# M0 — Creation Kit and Game Pass toolchain validation

## Objective

Establish what **this machine** can author and run with Steam-installed Creation Kit and PC Game Pass Starfield. Test the configuration empirically; do not conflate official support statements with measured runtime behavior. **Xbox Creations remains a first-class target.** A successful Game Pass test does not prove Xbox compatibility, and an SFSE-powered PC feature is not an Xbox release path.

## Driver

From the repository root (Windows PowerShell 5.1+):

```powershell
New-Item -ItemType Directory -Force out/m0 | Out-Null
Copy-Item scripts/runbooks/m0-evidence.template.json out/m0/manual-results.json
.\scripts\Invoke-M0Toolchain.ps1 -CreationKitPath $ckExe -GamePath $gameExe -ManualResultsPath .\out\m0\manual-results.json
```

Set `$ckExe` and `$gameExe` to executable paths **or containing folders** before running. The script only probes presence and file version, then aggregates separately entered outcomes. It does not launch, deploy, compile, modify installed game files, or assert success. Output is `out/m0/toolchain-report.json`, ignored by Git; review/redact local paths before attaching it to an issue.

## Operator test matrix

Record `pass`, `fail`, `blocked`, or `not_run`, with notes and reproducible evidence, in `out/m0/manual-results.json`.

| Test ID | Action | Evidence / pass criterion |
|---|---|---|
| `ck_launch` | Start Steam-installed Creation Kit alongside the existing Game Pass installation. | CK launches without fatal error; note exact build and workaround if any. |
| `master_load` | Load `Starfield.esm` in CK. | Master resolves and editor is usable; capture any unresolved dependencies. |
| `plugin_save` | Create and save a small original `SCS_` test plugin in CK. | Save completes; file can be reopened in CK. |
| `papyrus_compile` | Compile a minimal original Papyrus script that calls `Debug.Trace` from a testable event. | Compilation succeeds with no errors; capture compiler output. |
| `gamepass_plugin_load` | Install the generated plugin using the Game Pass-compatible mechanism actually in use; enable on **disposable** test save. | Plugin is visibly active in game and loads without fatal errors. |
| `gamepass_script_execution` | Trigger the event in game and inspect available Papyrus logs. | A distinctive, timestamped trace appears once per trigger. |
| `sfse_gamepass_observation` | Optional: investigate the reported script-extender capability independently. | Note exact loader, build, runtime, dependencies and verified behavior; do not infer console support. |

If CK cannot launch or a test plugin cannot load, record `blocked`/`fail` without trying to hide it. Record application builds in `testContext`. Do not commit game executables, tools, Bethesda masters, private telemetry, compiled game assets, save files, or screenshots containing private account data.

## Closeout

1. Re-run `Invoke-M0Toolchain.ps1` after editing outcomes; attach the redacted JSON to a GitHub feasibility issue.
2. Document whether the tested paths are fully supported, experimentally working, or blocked.
3. Gate M1 (one NPC + workstation) on successful base-game Papyrus/plugin workflow. **SFSE must not become a required dependency for the Xbox-compatible core.**
4. When available, repeat portability checks on Steam runtime and on an actual Xbox target before making shipping claims.

## Exit criteria

`ck_launch`, `master_load`, `plugin_save`, `papyrus_compile`, `gamepass_plugin_load`, and `gamepass_script_execution` pass on the recorded setup. Optional SFSE observation is not gating. No production feature is considered tested by this runbook.
