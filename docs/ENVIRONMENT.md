# Development environment

## Required for authoring

1. Windows desktop with sufficiently strong hardware; Creation Kit Steam system requirement is at least **32 GB RAM**, Windows 10 21H1+, SSD and dedicated GPU. See its [Steam product page](https://store.steampowered.com/app/2722710/).
2. **Starfield purchased and installed on Steam**, because Bethesda says the Creation Kit *will not launch* without it: [Bethesda support](https://help.bethesda.net/app/answers/detail/a_id/73814/).
3. [Starfield: Creation Kit](https://store.steampowered.com/app/2722710/) (free tool, downloaded via Steam).
4. [Git](https://git-scm.com/downloads) and [Visual Studio Code](https://code.visualstudio.com/).
5. Python 3.11+ for local repository integrity checks; not needed for runtime gameplay.
6. **Optional only:** [SF1Edit](https://github.com/TES5Edit/TES5Edit) to inspect plugin records and conflicts.
7. **Optional and Steam-only:** [SFSE](https://github.com/ianpatt/sfse) for future native extension experiments. It **does not support Game Pass**.

## Current user setup: PC Game Pass

- You can plan, author original text/3D source, and run repo checks with the current setup.
- You cannot use the documented official Starfield Creation Kit authoring environment on a Game Pass-only installation.
- An independent Steam Starfield installation or a collaborator who owns it is necessary before CK-based tests can be completed.
- Game Pass remains a worthwhile **compatibility testing target** for normal Creations/ESM/Papyrus builds when available; test distribution/deployment rather than assuming it works.

## Optional 3D pipeline for later milestone

User's Hi3D outputs -> mesh inspection/cleanup in Blender -> game compatible NIF + `.mesh` + materials/DDS (with Starfield Blender Extension) -> collision test -> Creation Kit placement -> nav/pathing and LOD/performance review.

See the [Starfield Blender Extension](https://github.com/MrTrilB/StarfieldBlenderExtension/) and [July 2026 community workflow](https://github.com/monster-cookie/starfield-modding-notes/blob/master/Modding/BlenderToStarfield.md). Check Blender and extension versions for compatibility, and licenses before committing generated assets.

## Safe local practices

- Work on disposable mod test saves, not main campaign saves.
- Avoid uncontrolled updates on toolchain test day. Record the exact game and CK versions.
- Store game installation, extracted assets and compiler binaries outside Git.
- Test clean load order and common modded load order independently.
- Validate `Game Pass` and `Steam` explicitly as separate runtime targets.
