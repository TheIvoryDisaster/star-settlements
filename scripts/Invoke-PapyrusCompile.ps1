#requires -Version 5.1
<#
.SYNOPSIS
 Compile an original Starfield Papyrus script with the Creation Kit compiler.
.EXAMPLE
 .\scripts\Invoke-PapyrusCompile.ps1 -CreationKitRoot 'D:\SteamLibrary\steamapps\common\Starfield' -GameRoot 'E:\XboxGames\Starfield\Content'
#>
[CmdletBinding()]
param(
 [Parameter(Mandatory=$true)][string]$CreationKitRoot,
 [string]$GameRoot,
 [string]$SourceFile = 'src/papyrus/SCS_CompileSmokeTest.psc',
 [string]$FlagsFile,
 [string]$OutputDirectory = 'out/papyrus'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
function Get-FilePath([string]$path) {
 if (-not [IO.Path]::IsPathRooted($path)) { $path = Join-Path $repoRoot $path }
 if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "File not found: $path" }
 return (Resolve-Path -LiteralPath $path).Path
}
if (-not (Test-Path -LiteralPath $CreationKitRoot -PathType Container)) { throw "CreationKitRoot not found: $CreationKitRoot" }
$ckRoot = (Resolve-Path -LiteralPath $CreationKitRoot).Path
if ([string]::IsNullOrWhiteSpace($GameRoot)) { $GameRoot = $CreationKitRoot }
if (-not (Test-Path -LiteralPath $GameRoot -PathType Container)) { throw "GameRoot not found: $GameRoot" }
$gameRoot = (Resolve-Path -LiteralPath $GameRoot).Path
$compiler = Get-FilePath (Join-Path $ckRoot 'Tools\Papyrus Compiler\PapyrusCompiler.exe')
$source = Get-FilePath $SourceFile
if ([IO.Path]::GetExtension($source).ToLowerInvariant() -ne '.psc') { throw "Expected .psc: $source" }
$out = $OutputDirectory
if (-not [IO.Path]::IsPathRooted($out)) { $out = Join-Path $repoRoot $out }
New-Item -ItemType Directory -Path $out -Force | Out-Null
$out = (Resolve-Path -LiteralPath $out).Path
$roots = @($gameRoot, $ckRoot) | Select-Object -Unique
$imports = New-Object 'System.Collections.Generic.List[string]'
$imports.Add((Split-Path -Parent $source))
foreach ($root in $roots) {
 foreach ($folder in @('Data\Scripts\Source','Data\Scripts\Source\Base','Data\Scripts\Source\User')) {
  $path = Join-Path $root $folder
  if ((Test-Path -LiteralPath $path -PathType Container) -and -not $imports.Contains($path)) { $imports.Add($path) }
 }
}
if ($imports.Count -le 1) { throw 'No CK source folders found. Extract Tools\ContentResources.zip\Scripts to Data\Scripts\Source before compiling.' }
if ([string]::IsNullOrWhiteSpace($FlagsFile)) {
 foreach ($root in $roots) {
  foreach ($folder in @('Data\Scripts\Source','Data\Scripts\Source\Base','Tools\Papyrus Compiler')) {
   $candidate = Join-Path (Join-Path $root $folder) 'Starfield_Papyrus_Flags.flg'
   if (Test-Path -LiteralPath $candidate -PathType Leaf) { $FlagsFile = $candidate; break }
  }
  if (-not [string]::IsNullOrWhiteSpace($FlagsFile)) { break }
 }
}
if ([string]::IsNullOrWhiteSpace($FlagsFile)) { throw 'Starfield_Papyrus_Flags.flg not found. Extract sources or specify -FlagsFile.' }
$flags = Get-FilePath $FlagsFile
$pex = Join-Path $out ([IO.Path]::GetFileNameWithoutExtension($source) + '.pex')
$priorTime = $null
if (Test-Path -LiteralPath $pex -PathType Leaf) { $priorTime = (Get-Item -LiteralPath $pex).LastWriteTimeUtc }
$stdout = Join-Path $out 'compiler.stdout.txt'
$stderr = Join-Path $out 'compiler.stderr.txt'
$report = Join-Path $out 'compile-report.json'
$importArg = $imports -join ';'
$compilerArgs = @(
 ('"{0}"' -f $source),
 ('-i="{0}"' -f $importArg),
 ('-o="{0}"' -f $out),
 ('-f="{0}"' -f $flags)
) -join ' '
Write-Host "Compiling $source"
$proc = Start-Process -FilePath $compiler -ArgumentList $compilerArgs -WorkingDirectory $ckRoot -RedirectStandardOutput $stdout -RedirectStandardError $stderr -NoNewWindow -Wait -PassThru
$pexUpdated = (Test-Path -LiteralPath $pex -PathType Leaf) -and ($null -eq $priorTime -or (Get-Item -LiteralPath $pex).LastWriteTimeUtc -gt $priorTime)
$success = ($proc.ExitCode -eq 0 -and $pexUpdated)
$result = [ordered]@{
 schemaVersion = 1
 collectedAtUtc = [DateTime]::UtcNow.ToString('o')
 success = $success
 exitCode = $proc.ExitCode
 compiler = $compiler
 source = $source
 imports = @($imports)
 flags = $flags
 outputFile = $pex
 outputUpdated = $pexUpdated
 stdout = $stdout
 stderr = $stderr
 caveat = 'Successful compilation does not establish plugin attachment, in-game execution, or Xbox compatibility.'
}
$result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $report -Encoding UTF8
Get-Content -LiteralPath $stdout | ForEach-Object { Write-Host $_ }
Get-Content -LiteralPath $stderr | ForEach-Object { Write-Warning $_ }
Write-Host "Report: $report"
if (-not $success) { throw "Papyrus compilation failed or did not update .pex (exit $($proc.ExitCode))." }
Write-Host "Compiled: $pex"
