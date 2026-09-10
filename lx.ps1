# ============================================
#              REDX CLEANER FINAL
#                  By LuxRest
# ============================================

$ErrorActionPreference = "SilentlyContinue"

# -----------------------------
# AYARLAR
# -----------------------------

$processName = "RedXGameLibrary"
$redxPath = ""

$targets = @(
    "xinput1_4.dll",
    "version.dll",
    "appcache",
    "package",
    "dwmapi.dll"
)

$Host.UI.RawUI.WindowTitle = "REDX CLEANER | By LuxRest"

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

Clear-Host

# -----------------------------
# RENKLER
# -----------------------------

function Write-Center {
    param(
        [string]$Text,
        [ConsoleColor]$Color = "White"
    )

    $width = $Host.UI.RawUI.WindowSize.Width

    if ($Text.Length -lt $width) {
        $left = [Math]::Max(0, [int](($width - $Text.Length) / 2))
        Write-Host (" " * $left + $Text) -ForegroundColor $Color
    }
    else {
        Write-Host $Text -ForegroundColor $Color
    }
}

# -----------------------------
# LOADING
# -----------------------------

function Show-Loading {
    param(
        [string]$Text,
        [int]$Seconds = 1
    )

    $frames = @(
        "[•] ",
        "[••] ",
        "[•••] ",
        "[••] "
    )

    $end = (Get-Date).AddSeconds($Seconds)
    $i = 0

    while ((Get-Date) -lt $end) {
        Write-Host "`r$($frames[$i % $frames.Count])$Text   " -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 180
        $i++
    }

    Write-Host "`r[✓] $Text" -ForegroundColor Green
}

# -----------------------------
# DURUM
# -----------------------------

function Write-Status {
    param(
        [string]$Text,
        [string]$Type = "INFO"
    )

    switch ($Type) {
        "OK" {
            Write-Host "[✓] $Text" -ForegroundColor Green
        }

        "WARN" {
            Write-Host "[!] $Text" -ForegroundColor Yellow
        }

        "ERROR" {
            Write-Host "[✗] $Text" -ForegroundColor Red
        }

        "SKIP" {
            Write-Host "[→] $Text" -ForegroundColor DarkGray
        }

        default {
            Write-Host "[•] $Text" -ForegroundColor Cyan
        }
    }
}

# -----------------------------
# BOYUT HESAPLAMA
# -----------------------------

function Get-ItemSizeBytes {
    param(
        [string]$Path
    )

    try {

        if (Test-Path -LiteralPath $Path -PathType Leaf) {

            return (Get-Item -LiteralPath $Path -Force).Length
        }

        if (Test-Path -LiteralPath $Path -PathType Container) {

            $files = Get-ChildItem -LiteralPath $Path -Recurse -Force -File

            $total = 0

            foreach ($file in $files) {
                $total += $file.Length
            }

            return $total
        }

    } catch {}

    return 0
}

# -----------------------------
# BOYUT FORMAT
# -----------------------------

function Format-Size {
    param(
        [long]$Bytes
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

# -----------------------------
# BAŞLANGIÇ
# -----------------------------

Write-Host ""
Write-Center "╔══════════════════════════════════════════════╗" Magenta
Write-Center "║                                              ║" Magenta
Write-Center "║              REDX CLEANER FINAL              ║" Magenta
Write-Center "║                  By LuxRest                  ║" Magenta
Write-Center "║                                              ║" Magenta
Write-Center "╚══════════════════════════════════════════════╝" Magenta
Write-Host ""

$startTime = Get-Date

# -----------------------------
# SİSTEM KONTROLÜ
# -----------------------------

Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Center "SİSTEM KONTROLÜ" Cyan
Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

Show-Loading "Sistem hazırlanıyor..." 1

# -----------------------------
# REDX KONTROL
# -----------------------------

$redxProcess = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($redxProcess) {

    Write-Status "RedX çalışıyor, kapatılıyor..." "INFO"

    try {
        Stop-Process -Name $processName -Force
        Start-Sleep -Milliseconds 800

        if (-not (Get-Process -Name $processName -ErrorAction SilentlyContinue)) {
            Write-Status "RedX başarıyla kapatıldı" "OK"
        }
        else {
            Write-Status "RedX kapatılamadı" "ERROR"
        }

    } catch {
        Write-Status "RedX kapatılırken hata oluştu" "ERROR"
    }

}
else {

    Write-Status "RedX zaten çalışmıyor" "SKIP"
}

# -----------------------------
# STEAM KONTROL
# -----------------------------

$steamProcess = Get-Process -Name "steam" -ErrorAction SilentlyContinue

if ($steamProcess) {

    Write-Status "Steam çalışıyor, kapatılıyor..." "INFO"

    try {

        Stop-Process -Name "steam" -Force
        Start-Sleep -Seconds 2

        Write-Status "Steam kapatıldı" "OK"

    } catch {

        Write-Status "Steam kapatılırken hata oluştu" "ERROR"
    }

}
else {

    Write-Status "Steam zaten çalışmıyor" "SKIP"
}

# -----------------------------
# STEAM YOLU
# -----------------------------

Write-Host ""
Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Center "STEAM KONTROLÜ" Cyan
Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

$steamPath = $null

try {

    $steamPath = (Get-ItemProperty `
        -Path "HKCU:\Software\Valve\Steam" `
        -Name "SteamPath" `
        -ErrorAction SilentlyContinue).SteamPath

} catch {}

if ([string]::IsNullOrWhiteSpace($steamPath)) {

    Write-Status "Steam yolu kayıt defterinden bulunamadı" "ERROR"

}
elseif (-not (Test-Path -LiteralPath $steamPath)) {

    Write-Status "Steam klasörü bulunamadı" "ERROR"

}
else {

    Write-Status "Steam bulundu" "OK"
    Write-Host "      Yol: $steamPath" -ForegroundColor Gray
}

# -----------------------------
# TEMİZLEME
# -----------------------------

Write-Host ""
Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Center "TEMİZLEME İŞLEMİ" Cyan
Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

$deletedCount = 0
$notFoundCount = 0
$failedCount = 0
$totalCleaned = [long]0

if (-not $steamPath -or -not (Test-Path -LiteralPath $steamPath)) {

    Write-Status "Geçerli Steam klasörü bulunamadığı için işlem iptal edildi" "ERROR"

}
else {

    $index = 0
    $totalTargets = $targets.Count

    foreach ($target in $targets) {

        $index++

        $fullPath = Join-Path $steamPath $target

        Write-Host "[$index/$totalTargets] $target" -ForegroundColor White

        # -------------------------
        # KONTROL
        # -------------------------

        if (-not (Test-Path -LiteralPath $fullPath)) {

            Write-Host "      → Bulunamadı" -ForegroundColor DarkGray

            $notFoundCount++

            Write-Host ""
            continue
        }

        # -------------------------
        # BOYUT
        # -------------------------

        $sizeBytes = Get-ItemSizeBytes -Path $fullPath
        $sizeText = Format-Size -Bytes $sizeBytes

        Write-Host "      Boyut : $sizeText" -ForegroundColor Gray
        Write-Host "      İşlem : SİLİNİYOR..." -ForegroundColor Yellow

        # -------------------------
        # SİLME
        # -------------------------

        try {

            Remove-Item `
                -LiteralPath $fullPath `
                -Recurse `
                -Force `
                -ErrorAction Stop

            Start-Sleep -Milliseconds 300

            # ---------------------
            # DOĞRULAMA
            # ---------------------

            if (-not (Test-Path -LiteralPath $fullPath)) {

                Write-Host "      ✓ Başarıyla silindi" -ForegroundColor Green

                $deletedCount++
                $totalCleaned += $sizeBytes

            }
            else {

                Write-Host "      ✗ Silme doğrulanamadı" -ForegroundColor Red

                $failedCount++
            }

        }
        catch {

            Write-Host "      ✗ Silme işlemi başarısız" -ForegroundColor Red

            $failedCount++
        }

        Write-Host ""
    }
}

# -----------------------------
# STEAM BAŞLAT
# -----------------------------

Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Center "PROGRAMLAR YENİDEN BAŞLATILIYOR" Cyan
Write-Host "────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

$steamExe = $null

$possibleSteamPaths = @(
    $steamPath,
    "C:\Program Files (x86)\Steam",
    "C:\Program Files\Steam"
)

foreach ($path in $possibleSteamPaths) {

    if ($path) {

        $candidate = Join-Path $path "steam.exe"

        if (Test-Path -LiteralPath $candidate) {

            $steamExe = $candidate
            break
        }
    }
}

if ($steamExe) {

    try {

        Start-Process -FilePath $steamExe

        Write-Status "Steam yeniden başlatıldı" "OK"

    }
    catch {

        Write-Status "Steam başlatılamadı" "ERROR"
    }

}
else {

    Write-Status "Steam.exe bulunamadı" "WARN"
}

# -----------------------------
# REDX BAŞLAT
# -----------------------------

Start-Sleep -Seconds 2

if (-not [string]::IsNullOrWhiteSpace($redxPath)) {

    if (Test-Path -LiteralPath $redxPath) {

        try {

            Start-Process -FilePath $redxPath

            Write-Status "RedX yeniden başlatıldı" "OK"

        }
        catch {

            Write-Status "RedX başlatılamadı" "ERROR"
        }

    }
    else {

        Write-Status "RedX yolu bulunamadı" "WARN"
    }

}
else {

    Write-Status "RedX otomatik başlatma yolu tanımlı değil" "SKIP"
}

# -----------------------------
# SONUÇ
# -----------------------------

$endTime = Get-Date
$elapsed = $endTime - $startTime

Write-Host ""
Write-Host "════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Center "TEMİZLEME SONUCU" Magenta
Write-Host "════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

Write-Host "  ✓ Silinen        : $deletedCount" -ForegroundColor Green
Write-Host "  → Bulunamayan    : $notFoundCount" -ForegroundColor DarkGray
Write-Host "  ✗ Hatalı         : $failedCount" -ForegroundColor Red
Write-Host "  ★ Temizlenen     : $(Format-Size $totalCleaned)" -ForegroundColor Cyan
Write-Host "  ⏱ İşlem süresi   : $($elapsed.Minutes) dk $($elapsed.Seconds) sn" -ForegroundColor Gray

Write-Host ""
Write-Host "════════════════════════════════════════════════" -ForegroundColor Magenta

if ($failedCount -eq 0) {

    Write-Center "✓ TEMİZLEME BAŞARIYLA TAMAMLANDI" Green

}
else {

    Write-Center "! TEMİZLEME TAMAMLANDI, BAZI İŞLEMLER BAŞARISIZ" Yellow
}

Write-Host "════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

Write-Center "REDX CLEANER | By LuxRest" DarkGray

Start-Sleep -Seconds 5
