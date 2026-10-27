# Development environment

## Required for authoring

1. Windows desktop with sufficiently strong hardware; Creation Kit Steam system requirement is at least **32 GB RAM**, Windows 10 21H1+, SSD and dedicated GPU. See its [Steam product page](https://store.steampowered.com/app/2722710/).
2. **Starfield Creation Kit obtained via Steam.** The CK *Getting Started* documentation also describes configuring CK for the **Microsoft Store installation** by running `Tools/SetupUtilities/ExportEditorDirToTarget.bat` against `XboxGames/Starfield/Content`. This is our M0 target; record what works on the actual machine. [Archived CK documentation](https://files.catbox.moe/4xycfq.pdf) and [Bethesda support article](https://help.bethesda.net/app/answers/detail/a_id/73814/).
3. [Starfield: Creation Kit](https://store.steampowered.com/app/2722710/) (free tool, downloaded via Steam).
4. Git and a source editor of choice (the project uses PowerShell compiler runbooks; Visual Studio and VS Code are both acceptable for editing `.psc`).
5. Python 3.11+ for local repository integrity checks; not needed for runtime gameplay.
6. **Optional only:** [SF1Edit](https://github.com/TES5Edit/TES5Edit) to inspect plugin records and conflicts.
7. **Optional and Steam-only:** [SFSE](https://github.com/ianpatt/sfse) for future native extension experiments. It **does not support Game Pass**.

## Current user setup: PC Game Pass

- Installed: Creation Kit from Steam; Starfield on PC Game Pass.
- The Starfield CK *Getting Started* materials describe transferring the Steam CK editor files to a Microsoft Store game install with `ExportEditorDirToTarget.bat`. Verify the local result with the M0 runbook rather than assuming the editor is blocked.
- Use `scripts/Invoke-PapyrusCompile.ps1` for an isolated compiler smoke test, and record whether produced `.pex` scripts and CK plugin records load on Game Pass.
- A Steam-only native extension cannot be assumed compatible with Xbox Creations. Independently test portability and console distribution.

## Optional 3D pipeline for later milestone

User's Hi3D outputs -> mesh inspection/cleanup in Blender -> game compatible NIF + `.mesh` + materials/DDS (with Starfield Blender Extension) -> collision test -> Creation Kit placement -> nav/pathing and LOD/performance review.

See the [Starfield Blender Extension](https://github.com/MrTrilB/StarfieldBlenderExtension/) and [July 2026 community workflow](https://github.com/monster-cookie/starfield-modding-notes/blob/master/Modding/BlenderToStarfield.md). Check Blender and extension versions for compatibility, and licenses before committing generated assets.

## Safe local practices

- Work on disposable mod test saves, not main campaign saves.
- Avoid uncontrolled updates on toolchain test day. Record the exact game and CK versions.
- Store game installation, extracted assets and compiler binaries outside Git.
- Test clean load order and common modded load order independently.
- Validate `Game Pass` and `Steam` explicitly as separate runtime targets.
