$processName = "RedXGameLibrary"
$redxPath = ""

# ==============================
#       BY LUXREST
#    REDX CLEANER v1.0
# ==============================

$Host.UI.RawUI.WindowTitle = "RedX Cleaner | By LuxRest"

Clear-Host

function Write-Center {
    param([string]$Text, [ConsoleColor]$Color = "White")

    $width = $Host.UI.RawUI.WindowSize.Width
    $left = [Math]::Max(0, [Math]::Floor(($width - $Text.Length) / 2))

    Write-Host (" " * $left) -NoNewline
    Write-Host $Text -ForegroundColor $Color
}

function Show-Loading {
    param(
        [string]$Text,
        [int]$Seconds = 1
    )

    $chars = @("|", "/", "-", "\")
    $end = (Get-Date).AddSeconds($Seconds)
    $i = 0

    while ((Get-Date) -lt $end) {
        Write-Host "`r  [ $($chars[$i % $chars.Count]) ] $Text" -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
        $i++
    }

    Write-Host "`r  [ ✓ ] $Text" -ForegroundColor Green
}

function Write-Status {
    param(
        [string]$Status,
        [string]$Text,
        [ConsoleColor]$Color
    )

    Write-Host "  [$Status] " -NoNewline -ForegroundColor $Color
    Write-Host $Text
}

# ==============================
# HEADER
# ==============================

Write-Host ""
Write-Center "╔══════════════════════════════════════════════╗" Magenta
Write-Center "║                                              ║" Magenta
Write-Center "║              REDX CLEANER v1.0               ║" Magenta
Write-Center "║                 By LuxRest                   ║" Cyan
Write-Center "║                                              ║" Magenta
Write-Center "╚══════════════════════════════════════════════╝" Magenta
Write-Host ""

Show-Loading "Initializing RedX Cleaner..." 1

# ==============================
# REDX PROCESS
# ==============================

$redxProcess = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($redxProcess) {

    $redxPath = $redxProcess.Path

    Write-Status "✓" "RedXGameLibrary detected" Green

    Show-Loading "Stopping RedXGameLibrary..." 1

    Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue

    Write-Status "✓" "RedXGameLibrary stopped" Green

}
else {

    Write-Status "-" "RedXGameLibrary is not running" Yellow
}

Write-Host ""

# ==============================
# STEAM PROCESS
# ==============================

$steamProcess = Get-Process -Name "steam" -ErrorAction SilentlyContinue

if ($steamProcess) {

    Write-Status "✓" "Steam process detected" Green

    Show-Loading "Stopping Steam..." 2

    Stop-Process -Name "steam" -Force -ErrorAction SilentlyContinue

    Start-Sleep -Seconds 3

    Write-Status "✓" "Steam stopped successfully" Green
}
else {

    Write-Status "-" "Steam is not running" Yellow
}

Write-Host ""

# ==============================
# STEAM REGISTRY
# ==============================

$registryPath = "HKCU:\Software\Valve\Steam"

if (-not (Test-Path $registryPath)) {

    Write-Status "X" "Steam registry path not found" Red

    Write-Host ""
    Write-Center "Cleanup could not continue." Red
    Write-Host ""

    Pause
    Exit
}

$steamRegistry = Get-ItemProperty -Path $registryPath

$steamPath = $steamRegistry.SteamPath
$steamExe = $steamRegistry.SteamExe

if (-not $steamPath) {

    Write-Status "X" "Steam installation path not found" Red

    Pause
    Exit
}

$steamPath = $steamPath -replace '/', '\'

Write-Host ""
Write-Host "  Steam Directory:" -ForegroundColor DarkGray
Write-Host "  $steamPath" -ForegroundColor Gray
Write-Host ""

# ==============================
# CLEANUP
# ==============================

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

        Write-Host "  [ DELETE ] " -NoNewline -ForegroundColor Yellow
        Write-Host $target

        try {

            Remove-Item -Path $fullPath -Recurse -Force -ErrorAction Stop

            Write-Host "  [   ✓   ] " -NoNewline -ForegroundColor Green
            Write-Host "$target deleted successfully" -ForegroundColor Green

            $deleted++

        }
        catch {

            Write-Host "  [   X   ] " -NoNewline -ForegroundColor Red
            Write-Host "Failed to delete $target" -ForegroundColor Red

            $failed++
        }

    }
    else {

        Write-Host "  [ SKIP ] " -NoNewline -ForegroundColor DarkGray
        Write-Host "$target not found" -ForegroundColor DarkGray

        $notFound++
    }

    Start-Sleep -Milliseconds 300
}

# ==============================
# START STEAM
# ==============================

Write-Host ""
Write-Host "  ═══════════════════════════════════════════" -ForegroundColor DarkMagenta
Write-Host ""

if ($steamExe -and (Test-Path $steamExe)) {

    Show-Loading "Starting Steam..." 2

    Start-Process -FilePath $steamExe

    Write-Status "✓" "Steam started successfully" Green
}
else {

    Write-Status "!" "Steam executable could not be found" Yellow
}

# ==============================
# START REDX
# ==============================

if ($redxPath -and (Test-Path $redxPath)) {

    Start-Sleep -Seconds 1

    Show-Loading "Starting RedXGameLibrary..." 2

    Start-Process -FilePath $redxPath

    Write-Status "✓" "RedXGameLibrary started successfully" Green
}
else {

    Write-Status "-" "RedXGameLibrary executable path unavailable" Yellow
}

# ==============================
# SUMMARY
# ==============================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║              CLEANUP COMPLETE             ║" -ForegroundColor Magenta
Write-Host "  ╠══════════════════════════════════════════╣" -ForegroundColor Magenta
Write-Host "  ║  Deleted  : $deleted" -ForegroundColor Green
Write-Host "  ║  Not Found: $notFound" -ForegroundColor Yellow
Write-Host "  ║  Failed   : $failed" -ForegroundColor Red
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Write-Center "REDX CLEANER | By LuxRest" Cyan
Write-Center "Thank you for using LuxRest tools." DarkGray

Write-Host ""
Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
