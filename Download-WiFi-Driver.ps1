<#
.SYNOPSIS
    Zisha OS 1.0 - Offline Wi-Fi Firmware Downloader for HP 13th Gen Laptop
.DESCRIPTION
    Downloads Debian 12 (Bookworm) non-free Wi-Fi firmware .deb packages
    (Realtek, Intel iwlwifi, MediaTek/Misc) directly into E:\Zisha-OS-WiFi-Fix
    so you can install Wi-Fi drivers in Zisha OS without needing internet!
#>

$ErrorActionPreference = "Stop"
$OutDir = "E:\Zisha-OS-WiFi-Fix"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

# Copy the Linux installer script into E:\Zisha-OS-WiFi-Fix with LF line endings
$ScriptSrc = Join-Path $PSScriptRoot "wifi-fix\install-wifi-on-zisha-os.sh"
$ScriptContent = [System.IO.File]::ReadAllText($ScriptSrc) -replace "`r`n", "`n"
[System.IO.File]::WriteAllText("$OutDir\install-wifi-on-zisha-os.sh", $ScriptContent, (New-Object System.Text.UTF8Encoding $false))

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   Downloading Zisha OS Offline Wi-Fi Drivers to E:\Zisha-OS-WiFi-Fix" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan

$DebUrls = @(
    "http://ftp.debian.org/debian/pool/non-free-firmware/f/firmware-nonfree/firmware-realtek_20230210-5_all.deb",
    "http://ftp.debian.org/debian/pool/non-free-firmware/f/firmware-nonfree/firmware-iwlwifi_20230210-5_all.deb",
    "http://ftp.debian.org/debian/pool/non-free-firmware/f/firmware-nonfree/firmware-misc-nonfree_20230210-5_all.deb",
    "http://ftp.debian.org/debian/pool/non-free-firmware/f/firmware-nonfree/firmware-atheros_20230210-5_all.deb"
)

foreach ($Url in $DebUrls) {
    $FileName = Split-Path -Leaf $Url
    $Dest = Join-Path $OutDir $FileName
    Write-Host "[*] Downloading $FileName ..." -ForegroundColor Yellow
    curl.exe -L --progress-bar "$Url" -o "$Dest"
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host " [SUCCESS] Offline Wi-Fi Drivers saved to: E:\Zisha-OS-WiFi-Fix" -ForegroundColor Green
Write-Host " In Zisha OS, open E: drive and run:" -ForegroundColor Cyan
Write-Host "   sudo bash install-wifi-on-zisha-os.sh" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Green
explorer.exe $OutDir
