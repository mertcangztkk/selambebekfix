# ============================================================
#                  REDX CLEANER v2.0
#                     BY LUXREST
# ============================================================

$ErrorActionPreference = "SilentlyContinue"

$Version = "2.0"
$ProcessName = "RedXGameLibrary"
$SteamProcessName = "steam"

$Targets = @(
    "xinput1_4.dll",
    "version.dll",
    "appcache",
    "package",
    "dwmapi.dll"
)

$StartTime = Get-Date

# ============================================================
# RENKLER / UI
# ============================================================

$Host.UI.RawUI.WindowTitle = "REDX CLEANER v$Version | By LuxRest"

try {
    $Host.UI.RawUI.ForegroundColor = "White"
}
catch {}

Clear-Host

function Write-Line {
    param(
        [string]$Text = "",
        [ConsoleColor]$Color = "White"
    )

    Write-Host $Text -ForegroundColor $Color
}

function Write-Center {
    param(
        [string]$Text,
        [ConsoleColor]$Color = "White"
    )

    try {
        $Width = $Host.UI.RawUI.WindowSize.Width
        $Left = [Math]::Max(0, [int](($Width - $Text.Length) / 2))
    }
    catch {
        $Left = 2
    }

    Write-Host ((" " * $Left) + $Text) -ForegroundColor $Color
}

function Status {
    param(
        [string]$Icon,
        [string]$Text,
        [ConsoleColor]$Color = "White"
    )

    Write-Host "  [" -NoNewline -ForegroundColor DarkGray
    Write-Host $Icon -NoNewline -ForegroundColor $Color
    Write-Host "] " -NoNewline -ForegroundColor DarkGray
    Write-Host $Text -ForegroundColor White
}

function Loading {
    param(
        [string]$Text,
        [int]$Seconds = 1
    )

    $Frames = @("|", "/", "-", "\")
    $End = (Get-Date).AddSeconds($Seconds)
    $Index = 0

    while ((Get-Date) -lt $End) {

        $Frame = $Frames[$Index % $Frames.Count]

        Write-Host "`r  [$Frame] $Text   " `
            -NoNewline `
            -ForegroundColor Cyan

        Start-Sleep -Milliseconds 110

        $Index++
    }

    Write-Host "`r  [✓] $Text                         " `
        -ForegroundColor Green
}

function Get-ItemSize {
    param(
        [string]$Path
    )

    try {

        if ((Get-Item $Path).PSIsContainer) {

            $Size = (
                Get-ChildItem `
                    -Path $Path `
                    -Recurse `
                    -Force `
                    -File `
                    -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum
            ).Sum

            if (-not $Size) {
                return 0
            }

            return [int64]$Size
        }

        return [int64](Get-Item $Path -Force).Length

    }
    catch {

        return 0
    }
}

function Format-Size {
    param(
        [int64]$Bytes
    )

    if ($Bytes -ge 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    }

    if ($Bytes -ge 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    }

    if ($Bytes -ge 1KB) {
        return "{0:N2} KB" -f ($Bytes / 1KB)
    }

    return "$Bytes B"
}

function Show-Progress {
    param(
        [int]$Current,
        [int]$Total
    )

    if ($Total -le 0) {
        return
    }

    $Percent = [int](($Current / $Total) * 100)

    $BarLength = 30
    $Filled = [int](($Percent / 100) * $BarLength)

    $Bar = ("█" * $Filled) + ("░" * ($BarLength - $Filled))

    Write-Host "`r  [$Bar] $Percent%   " `
        -NoNewline `
        -ForegroundColor Cyan
}

# ============================================================
# HEADER
# ============================================================

Write-Host ""

Write-Center "╔══════════════════════════════════════════════════╗" Magenta
Write-Center "║                                                  ║" Magenta
Write-Center "║              REDX CLEANER v$Version              ║" Magenta
Write-Center "║                                                  ║" Magenta
Write-Center "║                    BY LUXREST                   ║" Cyan
Write-Center "║                                                  ║" Magenta
Write-Center "╚══════════════════════════════════════════════════╝" Magenta

Write-Host ""

Loading "LuxRest Cleaner başlatılıyor..." 1

# ============================================================
# SİSTEM KONTROLÜ
# ============================================================

Write-Host ""
Write-Host "  ───────────────────────────────────────────────" `
    -ForegroundColor DarkMagenta

Write-Center "SİSTEM KONTROLÜ" Cyan

Write-Host "  ───────────────────────────────────────────────" `
    -ForegroundColor DarkMagenta

Write-Host ""

Status "✓" "PowerShell ortamı hazır" Green

try {

    $WindowsVersion = [System.Environment]::OSVersion.Version

    Status "✓" "Windows tespit edildi ($WindowsVersion)" Green

}
catch {

    Status "!" "Windows sürümü alınamadı" Yellow
}

Status "✓" "Temizleme motoru hazır" Green

Write-Host ""

# ============================================================
# REDX KONTROLÜ
# ============================================================

Status "•" "RedXGameLibrary kontrol ediliyor..." Cyan

$RedxPath = $null

$RedxProcess = Get-Process `
    -Name $ProcessName `
    -ErrorAction SilentlyContinue

if ($RedxProcess) {

    try {
        $RedxPath = $RedxProcess.Path
    }
    catch {}

    Status "✓" "RedXGameLibrary çalışıyor" Green

    Loading "RedXGameLibrary kapatılıyor..." 1

    Stop-Process `
        -Name $ProcessName `
        -Force `
        -ErrorAction SilentlyContinue

    Start-Sleep -Milliseconds 800

    if (-not (Get-Process -Name $ProcessName -ErrorAction SilentlyContinue)) {

        Status "✓" "RedXGameLibrary başarıyla kapatıldı" Green

    }
    else {

        Status "!" "RedXGameLibrary kapatılamadı" Yellow
    }

}
else {

    Status "-" "RedXGameLibrary çalışmıyor" Yellow
}

Write-Host ""

# ============================================================
# STEAM KONTROLÜ
# ============================================================

Status "•" "Steam kontrol ediliyor..." Cyan

$SteamWasRunning = $false

$SteamProcess = Get-Process `
    -Name $SteamProcessName `
    -ErrorAction SilentlyContinue

if ($SteamProcess) {

    $SteamWasRunning = $true

    Status "✓" "Steam çalışıyor" Green

    Loading "Steam kapatılıyor..." 2

    Stop-Process `
        -Name $SteamProcessName `
        -Force `
        -ErrorAction SilentlyContinue

    Start-Sleep -Seconds 2

    if (-not (Get-Process -Name $SteamProcessName -ErrorAction SilentlyContinue)) {

        Status "✓" "Steam başarıyla kapatıldı" Green

    }
    else {

        Status "!" "Steam tamamen kapatılamadı" Yellow
    }

}
else {

    Status "-" "Steam zaten çalışmıyor" Yellow
}

Write-Host ""

# ============================================================
# STEAM KLASÖRÜ
# ============================================================

Write-Host "  ───────────────────────────────────────────────" `
    -ForegroundColor DarkMagenta

Write-Center "STEAM KONUMU" Cyan

Write-Host "  ───────────────────────────────────────────────" `
    -ForegroundColor DarkMagenta

Write-Host ""

$RegistryPath = "HKCU:\Software\Valve\Steam"

if (-not (Test-Path $RegistryPath)) {

    Status "X" "Steam kayıt defteri konumu bulunamadı" Red

    Write-Host ""
    Write-Center "TEMİZLEME BAŞARISIZ" Red
    Write-Host ""

    Start-Sleep -Seconds 5
    exit
}

$SteamRegistry = Get-ItemProperty `
    -Path $RegistryPath `
    -ErrorAction SilentlyContinue

$SteamPath = $SteamRegistry.SteamPath
$SteamExe = $SteamRegistry.SteamExe

if (-not $SteamPath) {

    Status "X" "Steam kurulum yolu bulunamadı" Red

    Write-Host ""
    Write-Center "TEMİZLEME BAŞARISIZ" Red
    Write-Host ""

    Start-Sleep -Seconds 5
    exit
}

$SteamPath = $SteamPath -replace '/', '\'

if (-not (Test-Path $SteamPath)) {

    Status "X" "Steam klasörü mevcut değil" Red

    Write-Host ""
    Write-Host "  $SteamPath" -ForegroundColor DarkGray
    Write-Host ""

    Start-Sleep -Seconds 5
    exit
}

Status "✓" "Steam klasörü bulundu" Green

Write-Host ""
Write-Host "  Konum:" -ForegroundColor DarkGray
Write-Host "  $SteamPath" -ForegroundColor Gray

Write-Host ""

# ============================================================
# TEMİZLEME
# ============================================================

Write-Host "  ───────────────────────────────────────────────" `
    -ForegroundColor DarkMagenta

Write-Center "TEMİZLEME BAŞLIYOR" Cyan

Write-Host "  ───────────────────────────────────────────────" `
    -ForegroundColor DarkMagenta

Write-Host ""

$DeletedCount = 0
$NotFoundCount = 0
$FailedCount = 0
$TotalCleanedBytes = [int64]0
$Current = 0
$Total = $Targets.Count

foreach ($Target in $Targets) {

    $Current++

    Show-Progress `
        -Current ($Current - 1) `
        -Total $Total

    Write-Host ""

    $FullPath = Join-Path $SteamPath $Target

    if (Test-Path $FullPath) {

        $Size = Get-ItemSize -Path $FullPath
        $ReadableSize = Format-Size -Bytes $Size

        Write-Host "  ┌─ " -NoNewline -ForegroundColor DarkGray
        Write-Host "$Target" -ForegroundColor Yellow
        Write-Host "  │  Boyut: $ReadableSize" -ForegroundColor DarkGray
        Write-Host "  │  İşlem: SİLİNİYOR..." -ForegroundColor Yellow

        try {

            Remove-Item `
                -Path $FullPath `
                -Recurse `
                -Force `
                -ErrorAction Stop

            Start-Sleep -Milliseconds 250

            if (-not (Test-Path $FullPath)) {

                $DeletedCount++
                $TotalCleanedBytes += $Size

                Write-Host "  └─ [✓] Başarıyla silindi" `
                    -ForegroundColor Green
            }
            else {

                $FailedCount++

                Write-Host "  └─ [X] Silinemedi" `
                    -ForegroundColor Red
            }

        }
        catch {

            $FailedCount++

            Write-Host "  └─ [X] Silme hatası" `
                -ForegroundColor Red
        }

    }
    else {

        $NotFoundCount++

        Write-Host "  [SKIP] " -NoNewline -ForegroundColor DarkGray
        Write-Host "$Target bulunamadı" -ForegroundColor DarkGray
    }

    Write-Host ""

    Show-Progress `
        -Current $Current `
        -Total $Total

    Write-Host ""

    Start-Sleep -Milliseconds 300
}

# ============================================================
# TEMİZLEME SONRASI
# ============================================================

Write-Host ""
Write-Host "  ───────────────────────────────────────────────" `
    -ForegroundColor DarkMagenta

Loading "Temizleme sonuçları hazırlanıyor..." 1

# ============================================================
# STEAM BAŞLAT
# ============================================================

Write-Host ""

if ($SteamExe -and (Test-Path $SteamExe)) {

    Loading "Steam yeniden başlatılıyor..." 2

    try {

        Start-Process `
            -FilePath $SteamExe `
            -ErrorAction Stop

        Status "✓" "Steam yeniden başlatıldı" Green

    }
    catch {

        Status "X" "Steam başlatılamadı" Red
    }

}
else {

    Status "!" "Steam.exe bulunamadı" Yellow
}

# ============================================================
# REDX BAŞLAT
# ============================================================

Write-Host ""

if ($RedxPath -and (Test-Path $RedxPath)) {

    Loading "RedXGameLibrary yeniden başlatılıyor..." 2

    try {

        Start-Process `
            -FilePath $RedxPath `
            -ErrorAction Stop

        Status "✓" "RedXGameLibrary yeniden başlatıldı" Green

    }
    catch {

        Status "X" "RedXGameLibrary başlatılamadı" Red
    }

}
else {

    Status "-" "RedXGameLibrary çalıştırılabilir yolu bulunamadı" Yellow
}

# ============================================================
# SÜRE
# ============================================================

$EndTime = Get-Date
$Duration = $EndTime - $StartTime

$DurationText = "{0:00} dk {1:00} sn" `
    -f [int]$Duration.TotalMinutes, $Duration.Seconds

$CleanedText = Format-Size -Bytes $TotalCleanedBytes

# ============================================================
# SONUÇ
# ============================================================

Write-Host ""
Write-Host ""

Write-Center "╔══════════════════════════════════════════════════╗" Magenta
Write-Center "║                                                  ║" Magenta
Write-Center "║               TEMİZLEME TAMAMLANDI              ║" Magenta
Write-Center "║                                                  ║" Magenta
Write-Center "╠══════════════════════════════════════════════════╣" Magenta
Write-Center "║                                                  ║" Magenta

Write-Center "║   Silinen öğe       : $DeletedCount" Green
Write-Center "║   Bulunamayan       : $NotFoundCount" Yellow
Write-Center "║   Başarısız         : $FailedCount" Red
Write-Center "║   Temizlenen alan   : $CleanedText" Cyan
Write-Center "║   İşlem süresi      : $DurationText" Cyan

Write-Center "║                                                  ║" Magenta
Write-Center "╚══════════════════════════════════════════════════╝" Magenta

Write-Host ""

if ($FailedCount -eq 0) {

    Write-Center "✓ İşlem başarıyla tamamlandı." Green

}
else {

    Write-Center "! İşlem tamamlandı ancak bazı işlemler başarısız oldu." Yellow
}

Write-Host ""

Write-Center "REDX CLEANER v$Version" Cyan
Write-Center "BY LUXREST" Magenta

Write-Host ""
Write-Center "Pencere 5 saniye içinde kapanacak..." DarkGray

Start-Sleep -Seconds 5
