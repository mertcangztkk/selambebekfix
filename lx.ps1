# ============================================
#              REDX CLEANER v1.0
#                  By LuxRest
# ============================================

$ErrorActionPreference = "SilentlyContinue"

# ---------- UI ----------
$Host.UI.RawUI.WindowTitle = "REDX CLEANER | By LuxRest"

Clear-Host

function Write-Center {
    param(
        [string]$Text,
        [ConsoleColor]$Color = "White"
    )

    try {
        $width = $Host.UI.RawUI.WindowSize.Width
        $left = [Math]::Max(0, [int](($width - $Text.Length) / 2))
    }
    catch {
        $left = 2
    }

    Write-Host ((" " * $left) + $Text) -ForegroundColor $Color
}

function Loading {
    param(
        [string]$Text,
        [int]$Seconds = 1
    )

    $chars = @("|", "/", "-", "\")
    $end = (Get-Date).AddSeconds($Seconds)
    $i = 0

    while ((Get-Date) -lt $end) {
        Write-Host "`r  [$($chars[$i % $chars.Count])] $Text   " -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
        $i++
    }

    Write-Host "`r  [✓] $Text                     " -ForegroundColor Green
}

function Status {
    param(
        [string]$Symbol,
        [string]$Text,
        [ConsoleColor]$Color = "White"
    )

    Write-Host "  [$Symbol] " -NoNewline -ForegroundColor $Color
    Write-Host $Text
}

# ---------- HEADER ----------

Write-Host ""
Write-Center "╔══════════════════════════════════════════════╗" Magenta
Write-Center "║                                              ║" Magenta
Write-Center "║              REDX CLEANER v1.0              ║" Magenta
Write-Center "║                 By LuxRest                  ║" Cyan
Write-Center "║                                              ║" Magenta
Write-Center "╚══════════════════════════════════════════════╝" Magenta
Write-Host ""

Loading "Initializing..." 1

# ---------- REDX ----------

$processName = "RedXGameLibrary"
$redxPath = $null

$redxProcess = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($redxProcess) {

    try {
        $redxPath = $redxProcess.Path
    } catch {}

    Status "✓" "RedXGameLibrary detected" Green

    Loading "Stopping RedXGameLibrary..." 1

    Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue

    Status "✓" "RedXGameLibrary stopped" Green
}
else {
    Status "-" "RedXGameLibrary is not running" Yellow
}

Write-Host ""

# ---------- STEAM ----------

$steamProcess = Get-Process -Name "steam" -ErrorAction SilentlyContinue

if ($steamProcess) {

    Status "✓" "Steam detected" Green

    Loading "Stopping Steam..." 2

    Stop-Process -Name "steam" -Force -ErrorAction SilentlyContinue

    Start-Sleep -Seconds 3

    Status "✓" "Steam stopped" Green
}
else {
    Status "-" "Steam is not running" Yellow
}

Write-Host ""

# ---------- STEAM PATH ----------

$registryPath = "HKCU:\Software\Valve\Steam"

if (-not (Test-Path $registryPath)) {

    Status "X" "Steam registry entry not found" Red

    Write-Host ""
    Write-Center "CLEANUP FAILED" Red
    Write-Host ""

    Start-Sleep -Seconds 3
    exit
}

$steamRegistry = Get-ItemProperty -Path $registryPath

$steamPath = $steamRegistry.SteamPath
$steamExe = $steamRegistry.SteamExe

if (-not $steamPath) {

    Status "X" "Steam installation path not found" Red

    Start-Sleep -Seconds 3
    exit
}

$steamPath = $steamPath -replace '/', '\'

Write-Host "  Steam Directory:" -ForegroundColor DarkGray
Write-Host "  $steamPath" -ForegroundColor Gray
Write-Host ""

# ---------- CLEANUP ----------

$targets = @(
    "xinput1_4.dll",
    "version.dll",
    "appcache",
    "package",
    "dwmapi.dll"
)

$deleted = 0
$notFound = 0
$failed = 0

Write-Host "  ═══════════════════════════════════════════" -ForegroundColor DarkMagenta
Write-Host "                 CLEANUP" -ForegroundColor Cyan
Write-Host "  ═══════════════════════════════════════════" -ForegroundColor DarkMagenta
Write-Host ""

foreach ($target in $targets) {

    $fullPath = Join-Path $steamPath $target

    if (Test-Path $fullPath) {

        Write-Host "  [DELETE] " -NoNewline -ForegroundColor Yellow
        Write-Host $target

        try {

            Remove-Item `
                -Path $fullPath `
                -Recurse `
                -Force `
                -ErrorAction Stop

            if (-not (Test-Path $fullPath)) {

                Write-Host "  [  ✓  ] " -NoNewline -ForegroundColor Green
                Write-Host "$target deleted"

                $deleted++
            }
            else {

                Write-Host "  [  X  ] " -NoNewline -ForegroundColor Red
                Write-Host "$target could not be deleted"

                $failed++
            }
        }
        catch {

            Write-Host "  [  X  ] " -NoNewline -ForegroundColor Red
            Write-Host "Failed: $target"

            $failed++
        }

    }
    else {

        Write-Host "  [ SKIP ] " -NoNewline -ForegroundColor DarkGray
        Write-Host "$target not found"

        $notFound++
    }

    Start-Sleep -Milliseconds 250
}

# ---------- START STEAM ----------

Write-Host ""
Write-Host "  ═══════════════════════════════════════════" -ForegroundColor DarkMagenta
Write-Host ""

if ($steamExe -and (Test-Path $steamExe)) {

    Loading "Starting Steam..." 2

    Start-Process -FilePath $steamExe

    Status "✓" "Steam started" Green
}
else {

    Status "!" "Steam executable not found" Yellow
}

# ---------- START REDX ----------

if ($redxPath -and (Test-Path $redxPath)) {

    Start-Sleep -Seconds 1

    Loading "Starting RedXGameLibrary..." 2

    Start-Process -FilePath $redxPath

    Status "✓" "RedXGameLibrary started" Green
}
else {

    Status "-" "RedX executable path unavailable" Yellow
}

# ---------- RESULT ----------

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║              CLEANUP COMPLETE            ║" -ForegroundColor Magenta
Write-Host "  ╠══════════════════════════════════════════╣" -ForegroundColor Magenta
Write-Host "  ║  Deleted   : $deleted" -ForegroundColor Green
Write-Host "  ║  Not Found : $notFound" -ForegroundColor Yellow
Write-Host "  ║  Failed    : $failed" -ForegroundColor Red
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Write-Center "REDX CLEANER | By LuxRest" Cyan
Write-Center "Operation completed successfully." DarkGray

Write-Host ""
Write-Host "  Closing in 5 seconds..." -ForegroundColor DarkGray

Start-Sleep -Seconds 5
