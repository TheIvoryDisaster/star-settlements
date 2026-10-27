#requires -Version 5.1
<#
.SYNOPSIS
    Read-only diagnostics for PC Game Pass Starfield launch failures.
.DESCRIPTION
    Collects the registered Xbox package and checks the editable XboxGames copy.
    Does NOT launch the game, touch WindowsApps, repair files, or change mod state.
.EXAMPLE
    .\scripts\Invoke-StarfieldLaunchDiagnostics.ps1 -GameRoot 'C:\XboxGames\Starfield\Content'
#>
[CmdletBinding()]
param(
    [string] $GameRoot = 'C:\XboxGames\Starfield\Content',
    [string] $OutputPath = 'out/m0/launch-diagnostics.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path

function Get-PeMachine {
    param([string] $FilePath)
    $stream = $null
    $reader = $null
    try {
        $stream = [System.IO.File]::Open($FilePath, [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $reader = New-Object System.IO.BinaryReader($stream)
        if ($reader.ReadUInt16() -ne 0x5A4D) { return 'invalid_MZ_header' }
        if ($stream.Length -lt 64) { return 'truncated_header' }
        $stream.Position = 0x3C
        $peOffset = $reader.ReadInt32()
        if ($peOffset -lt 64 -or $peOffset -gt ($stream.Length - 6)) { return 'invalid_PE_offset' }
        $stream.Position = $peOffset
        if ($reader.ReadUInt32() -ne 0x4550) { return 'invalid_PE_signature' }
        $machine = $reader.ReadUInt16()
        switch ($machine) {
            0x8664 { return 'x64 (0x8664)' }
            0x014c { return 'x86 (0x014c)' }
            0xAA64 { return 'ARM64 (0xAA64)' }
            default { return ('unknown (0x{0:X4})' -f $machine) }
        }
    } catch {
        return ('unavailable: ' + $_.Exception.Message)
    } finally {
        if ($null -ne $reader) { $reader.Dispose() }
        elseif ($null -ne $stream) { $stream.Dispose() }
    }
}

function Get-ExecutableInfo {
    param([string] $FilePath)
    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        return [ordered]@{ status = 'not_found'; path = $FilePath }
    }
    $item = Get-Item -LiteralPath $FilePath
    $signature = $null
    try { $signature = (Get-AuthenticodeSignature -LiteralPath $FilePath).Status.ToString() }
    catch { $signature = 'unavailable: ' + $_.Exception.Message }
    return [ordered]@{
        status = 'found'
        path = $item.FullName
        sizeBytes = $item.Length
        lastWriteTimeUtc = $item.LastWriteTimeUtc.ToString('o')
        fileVersion = [string]$item.VersionInfo.FileVersion
        productVersion = [string]$item.VersionInfo.ProductVersion
        peMachine = Get-PeMachine -FilePath $FilePath
        authenticodeStatus = $signature
    }
}

$package = [ordered]@{ status = 'unavailable' }
try {
    $registered = Get-AppxPackage -Name 'BethesdaSoftworks.ProjectGold' -ErrorAction Stop |
        Select-Object -First 1
    if ($null -ne $registered) {
        $package = [ordered]@{
            status = 'registered'
            name = $registered.Name
            version = [string]$registered.Version
            packageFullName = $registered.PackageFullName
            installLocation = $registered.InstallLocation
        }
    } else {
        $package.status = 'not_registered_for_current_user'
    }
} catch {
    $package.status = 'query_failed'
    $package.error = $_.Exception.Message
}

$gameExe = Join-Path $GameRoot 'Starfield.exe'
$gameRootExists = Test-Path -LiteralPath $GameRoot -PathType Container
$similarFiles = @()
if ($gameRootExists) {
    $similarFiles = @(Get-ChildItem -LiteralPath $GameRoot -File -Filter 'Starfield*.exe' -ErrorAction SilentlyContinue |
        ForEach-Object { [ordered]@{ name = $_.Name; sizeBytes = $_.Length } })
}

$report = [ordered]@{
    schemaVersion = 1
    capturedAtUtc = [DateTime]::UtcNow.ToString('o')
    system = [ordered]@{
        os64Bit = [Environment]::Is64BitOperatingSystem
        process64Bit = [Environment]::Is64BitProcess
    }
    xboxPackage = $package
    editableInstall = [ordered]@{
        gameRoot = $GameRoot
        rootExists = $gameRootExists
        starfieldExecutable = Get-ExecutableInfo -FilePath $gameExe
        otherStarfieldExecutables = $similarFiles
    }
    caveats = @(
        'This diagnostic deliberately does not read or modify protected WindowsApps executables.',
        'An Authenticode NotSigned result alone does not establish that an installed game executable is corrupt.',
        'Executable inspection alone does not prove the Xbox game package will launch.',
        'The diagnostic is read-only and never verifies or repairs game files.',
        'Paths may contain user or installation details. Review before posting publicly.'
    )
}

$target = $OutputPath
if (-not [System.IO.Path]::IsPathRooted($target)) {
    $target = Join-Path $repoRoot $target
}
$parent = Split-Path -Parent $target
if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $target -Encoding UTF8
Write-Host "Saved diagnostic report to $target"
Write-Host "Xbox package: $($package.status)"
Write-Host "Editable game executable: $($report.editableInstall.starfieldExecutable.status)"
Write-Host 'No files in the game installation were changed.'
