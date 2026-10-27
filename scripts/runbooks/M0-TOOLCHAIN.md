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

## Known setup issue: missing Steamworks DLL on Game Pass

For PC Game Pass installations, the Steam Creation Kit package includes `Tools/SetupUtilities/ExportEditorDirToTarget.bat` and `Tools/SetupUtilities/Dependencies/steam_api64.dll`. If `steam_api64.dll` or `libxess.dll` is missing on launch:

1. From the **Steam Creation Kit installation**, execute `Tools/SetupUtilities/ExportEditorDirToTarget.bat` with the **Game Pass Starfield `Content` directory** as its target. For example, `ExportEditorDirToTarget.bat "D:\\XboxGames\\Starfield\\Content"`.
2. Launch the resulting `CreationKit.exe` **in the Game Pass `Content` folder**.
3. If the target `CreationKit.exe` still reports missing `steam_api64.dll`, first check whether `Tools/SetupUtilities/Dependencies/steam_api64.dll` exists in the Steam CK package; if it does, check if it was copied alongside the launched executable. Prefer an intact installation and rerunning the provided setup utility before manually copying its bundled DLL into that same executable directory.
4. If the bundled DLL is absent, use Steam's **Verify integrity of tool files** for Creation Kit. Never download DLLs from arbitrary websites, rename DLLs, or copy them to System32.

This setup is documented in the Starfield Creation Kit *Getting Started* materials under "Setting up the Starfield Creation Kit for the Microsoft Store Version" (see [archived PDF, pages 1–2](https://files.catbox.moe/4xycfq.pdf)). Record actual behavior in the M0 test matrix; a successful launch does not prove editing, compilation, or Xbox compatibility.

References: [Steam community CK setup discussion](https://steamcommunity.com/app/2722710/discussions/0/4849904176637348800/), [SteamDB distributed files](https://steamdb.info/depot/2722711/apps/), [Bethesda CK support policy](https://help.bethesda.net/app/answers/detail/a_id/73814/).

## Compile the Papyrus smoke test

The Starfield Creation Kit ships its own compiler under `Tools\\Papyrus Compiler\\PapyrusCompiler.exe`. Its script reference source comes from `Tools\\ContentResources.zip` (`Scripts/`), extracted to `Data\\Scripts\\Source` under the active Starfield/CK directory. Preserve folder structure, including `Base/` and the `Starfield_Papyrus_Flags.flg` file. The active `CreationKitCustom.ini` should contain:

```ini
[Papyrus]
sScriptSourceFolder="Data/Scripts/Source"
```

This repository includes `src/papyrus/SCS_CompileSmokeTest.psc` and a command-line harness that writes a compiled `.pex` and capture files **only** to the ignored `out/papyrus` folder:

```powershell
.\\scripts\\Invoke-PapyrusCompile.ps1 -CreationKitRoot 'D:\\SteamLibrary\\steamapps\\common\\Starfield' -GameRoot 'E:\\XboxGames\\Starfield\\Content'
```

Set those paths to the actual Steam CK installation and active PC Game Pass game directory. If all required CK assets were copied to the Game Pass location, `-CreationKitRoot` can point there instead. Use `-FlagsFile` to override flag-file discovery if your installation is arranged differently. `out/papyrus/compile-report.json`, `compiler.stdout.txt`, and `compiler.stderr.txt` capture the result.

Alternatively, copy the same `.psc` into the editor's active `Data\\Scripts\\Source` folder, open **Gameplay → Papyrus Script Manager**, locate the script, and select **Compile**. The editor can produce `Data\\Scripts\\SCS_CompileSmokeTest.pex`.

**What a pass means:** The CK compiler accepts this original `ObjectReference` script and emits a new `.pex`. This does *not* mean `OnActivate` has run: attach the script to a suitable object in a saved plugin and activate that object in-game for the separate runtime test. Do not copy `.pex` into the live game automatically during this spike.

Sources: [Starfield Creation Kit setup materials](https://files.catbox.moe/4xycfq.pdf), [Starfield Papyrus command-line resources](https://www.nexusmods.com/starfield/mods/10320).

## Closeout

1. Re-run `Invoke-M0Toolchain.ps1` after editing outcomes; attach the redacted JSON to a GitHub feasibility issue.
2. Document whether the tested paths are fully supported, experimentally working, or blocked.
3. Gate M1 (one NPC + workstation) on successful base-game Papyrus/plugin workflow. **SFSE must not become a required dependency for the Xbox-compatible core.**
4. When available, repeat portability checks on Steam runtime and on an actual Xbox target before making shipping claims.

## Exit criteria

`ck_launch`, `master_load`, `plugin_save`, `papyrus_compile`, `gamepass_plugin_load`, and `gamepass_script_execution` pass on the recorded setup. Optional SFSE observation is not gating. No production feature is considered tested by this runbook.
