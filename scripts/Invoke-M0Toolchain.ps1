#requires -Version 5.1
<#
.SYNOPSIS
  Collects M0 development-toolchain diagnostics and operator test evidence.
.DESCRIPTION
  Read-only: no game launches, deployments, plugin edits, or registry writes.
  The generated JSON is local-only under out/ (gitignored). Manual outcomes
  must be independently observed; executable detection never marks a test passed.
.EXAMPLE
  .\scripts\Invoke-M0Toolchain.ps1 -CreationKitPath $ckExe -GamePath $gameExe -ManualResultsPath .\out\m0\manual-results.json
#>
[CmdletBinding()]
param(
    [string] $CreationKitPath,
    [string] $GamePath,
    [string] $ManualResultsPath,
    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-ExecutableProbe {
    param([string] $Candidate, [string[]] $Names)
    if ([string]::IsNullOrWhiteSpace($Candidate)) {
        return [ordered]@{ status = 'not_provided'; path = $null; fileVersion = $null }
    }
    $resolved = $null
    if (Test-Path -LiteralPath $Candidate -PathType Leaf) {
        $resolved = (Resolve-Path -LiteralPath $Candidate).Path
    } elseif (Test-Path -LiteralPath $Candidate -PathType Container) {
        foreach ($name in $Names) {
            $path = Join-Path $Candidate $name
            if (Test-Path -LiteralPath $path -PathType Leaf) {
                $resolved = (Resolve-Path -LiteralPath $path).Path
                break
            }
        }
    }
    if ($null -eq $resolved) {
        return [ordered]@{ status = 'not_found'; path = $Candidate; fileVersion = $null }
    }
    $info = (Get-Item -LiteralPath $resolved).VersionInfo
    return [ordered]@{ status = 'found'; path = $resolved; fileVersion = [string]$info.FileVersion }
}

$caseIds = @(
    'ck_launch', 'master_load', 'plugin_save', 'papyrus_compile',
    'gamepass_plugin_load', 'gamepass_script_execution', 'sfse_gamepass_observation'
)
$statuses = @('not_run', 'pass', 'fail', 'blocked')
$evidence = $null
if (-not [string]::IsNullOrWhiteSpace($ManualResultsPath)) {
    if (-not (Test-Path -LiteralPath $ManualResultsPath -PathType Leaf)) {
        throw "Manual evidence file not found: $ManualResultsPath"
    }
    $evidence = Get-Content -LiteralPath $ManualResultsPath -Raw | ConvertFrom-Json
    if ($null -eq $evidence.manualResults) {
        throw 'Evidence JSON must contain a manualResults object.'
    }
}

$manual = [ordered]@{}
foreach ($id in $caseIds) {
    $value = $null
    if ($null -ne $evidence) {
        $property = $evidence.manualResults.PSObject.Properties[$id]
        if ($null -ne $property) { $value = $property.Value }
    }
    $status = 'not_run'
    $notes = ''
    if ($null -ne $value) {
        if ($null -ne $value.status) { $status = [string]$value.status }
        if ($null -ne $value.notes) { $notes = [string]$value.notes }
    }
    if ($statuses -notcontains $status) {
        throw "Invalid status '$status' for '$id'. Allowed: $($statuses -join ', ')"
    }
    $manual[$id] = [ordered]@{ status = $status; notes = $notes }
}

$context = [ordered]@{}
if ($null -ne $evidence -and $null -ne $evidence.testContext) {
    foreach ($prop in $evidence.testContext.PSObject.Properties) {
        $context[$prop.Name] = $prop.Value
    }
}

$report = [ordered]@{
    schemaVersion = 1
    collectedAtUtc = [DateTime]::UtcNow.ToString('o')
    environment = [ordered]@{
        osDescription = [System.Environment]::OSVersion.VersionString
        powershellVersion = $PSVersionTable.PSVersion.ToString()
    }
    executables = [ordered]@{
        creationKit = (Get-ExecutableProbe -Candidate $CreationKitPath -Names @('CreationKit.exe', 'CreationKit64.exe'))
        starfield = (Get-ExecutableProbe -Candidate $GamePath -Names @('Starfield.exe'))
    }
    testContext = $context
    manualResults = $manual
    caveat = 'Executable detection does not prove CK authoring, Papyrus compilation, Game Pass compatibility, or Xbox compatibility.'
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repoRoot 'out/m0/toolchain-report.json'
}
$parent = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
$report | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host "Wrote M0 diagnostic: $OutputPath"
Write-Host "CK: $($report.executables.creationKit.status) | Game: $($report.executables.starfield.status)"
Write-Host 'Manual tests remain not_run until evidence is explicitly recorded.'
