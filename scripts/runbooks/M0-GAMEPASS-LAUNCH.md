# M0 — PC Game Pass executable launch failure (Win64 incompatibility dialog)

## Symptom

Windows reports that an executable such as:

```text
C:\Program Files\WindowsApps\BethesdaSoftworks.ProjectGold_1.16.244.0_x64__...\Starfield.exe
The program or feature ... cannot start or run due to incompatibility with 64-bit versions of Windows.
```

The WindowsApps path is a normal Microsoft Store package location. The error does **not** by itself prove an actual x86/x64 mismatch. A corrupted/replaced executable, wrong launch path, broken package registration, or external loader conflict are possibilities. A compiled Papyrus `.pex` file is not executable at process startup and cannot by itself cause this OS-level rejection.

## Priority triage (no file modifications)

1. Launch Starfield using **Xbox App → Starfield → Play**, not a direct WindowsApps executable, custom shortcut, or script-extender loader. Record whether this produces the same exact error.
2. Read-only inspection from repository root:

   ```powershell
   .\scripts\Invoke-StarfieldLaunchDiagnostics.ps1 -GameRoot 'C:\XboxGames\Starfield\Content'
   ```

   Use the actual Xbox app installation directory if different. The script records Microsoft Store package registration, editable-install Starfield.exe presence, size, version, architecture header, and signing status. It **does not touch protected WindowsApps paths** or modify the game. JSON output is at `out/m0/launch-diagnostics.json` (gitignored).
3. Record any use of executable-wrapping tools or `Starfield.exe` renames performed for SFSE/Game Pass workarounds. Do not copy Steam executables or arbitrary DLLs into WindowsApps or attempt to take ownership of the directory.

## Restore through the platform

If the **normal Xbox Play button fails**:

1. Back up any manually deployed mods/test scripts/plugin files and any non-cloud local saves you care about. Keep the backup *outside* game installation directories.
2. Open **Xbox app → Starfield → ... → Manage → Files → Verify and Repair**. Bethesda explicitly warns that unbacked-up mods or saves may not be retained through this process.
3. Launch again from the Xbox app after verification. If the repair succeeds, reapply only the confirmed-good Creation Kit setup resources needed for authoring, not a Steam `Starfield.exe` or native loader.
4. If still failing, consider repairing/updating Xbox Gaming Services and the Xbox app via Windows/Microsoft Store, and examine Windows Reliability Monitor or Event Viewer for the actual executable load error. Game reinstall is a later escalation, not step one.

## Diagnostics and interpretation

- `x64 (0x8664)` in the local executable's PE header is consistent with a 64-bit binary, but does not prove it is a valid or intact Microsoft-supplied binary.
- `invalid_MZ_header`, `invalid_PE_signature` or an unexpectedly tiny executable makes corruption/replacement more plausible.
- `xboxPackage.status = registered` confirms package registration for the current user, not a healthy game install.
- `authenticodeStatus = NotSigned` *alone* should not be used to conclude Microsoft Store package corruption.
- If the Xbox app launches the game but a custom launcher doesn't, isolate the custom launcher before repairing the game.

## Safe outcome and next step

Record which path launched successfully, whether Xbox Verify and Repair replaced files, and post a **redacted** diagnostic if needed. Return to Papyrus runtime smoke testing only after the unmodified game launches reliably.

## References

- [Bethesda: Verify and Repair in Xbox App](https://help.bethesda.net/app/answers/detail/a_id/59736/)
- [Bethesda: Starfield won't launch on PC](https://help.bethesda.net/app/answers/detail/a_id/61091/)
- [SFSE Game Pass investigation: package identity and launcher considerations](https://github.com/ianpatt/sfse/issues/10)
- [Nexus Mods Starfield extension: WindowsApps vs. XboxGames editable paths](https://github.com/Nexus-Mods/game-starfield)
