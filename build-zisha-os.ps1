<#
.SYNOPSIS
    Zisha OS 1.0 — Master Builder & Management Script for Windows
.DESCRIPTION
    Builds the custom Zisha OS 1.0 (AI, Web Dev, Security & Bangla/English Office Edition)
    bootable .ISO file using Docker, WSL2, or GitHub Cloud Actions, validates system modules,
    opens the built-in Master Control Center & Offline Bangla Converter, and syncs to Zisha-OS.
.PARAMETER Action
    Validate            - Checks all Zisha OS configurations, modules, and tools
    BuildISO            - Builds zisha-os-1.0-amd64.iso using Docker or WSL2
    OpenControlCenter   - Opens the Zisha OS 1.0 Master Control Center (AI, Security, ISO & Office Hub)
    OpenBanglaConverter - Launches the offline Zisha OS Bangla (Unicode <-> Bijoy) Converter
    SyncProjectFolder   - Syncs project files to C:\Users\HP\Documents\antigravity\Zisha-OS
#>

param(
    [ValidateSet("Validate", "BuildISO", "OpenControlCenter", "OpenBanglaConverter", "SyncProjectFolder")]
    [string]$Action = "Validate"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetZishaFolder = Join-Path (Split-Path -Parent $ProjectRoot) "Zisha-OS"

function Write-ZishaBanner {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "   _____ _     _             ___  ____   " -ForegroundColor Green
    Write-Host "  |__  /(_)___| |__   __ _  / _ \/ ___|  " -ForegroundColor Green
    Write-Host "    / / | / __| '_ \ / _`` || | | \___ \  " -ForegroundColor Green
    Write-Host "   / /_ | \__ \ | | | (_| || |_| |___) | " -ForegroundColor Green
    Write-Host "  /____||_|___/_| |_|\__,_| \___/|____/  v1.0 (AI, Dev & Office Edition)" -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-Validate {
    Write-ZishaBanner
    Write-Host "[*] Validating Zisha OS 1.0 project structure and modules..." -ForegroundColor Yellow

    $RequiredFiles = @(
        "Dockerfile.isobuilder",
        ".github/workflows/build-zisha-os-iso.yml",
        "config/preseed/zisha-os-preseed.cfg",
        "scripts/build-iso.sh",
        "scripts/install-on-existing-linux.sh",
        "scripts/modules/01-security-performance.sh",
        "scripts/modules/02-bengali-english-office.sh",
        "scripts/modules/03-webdev-ai-stack.sh",
        "scripts/modules/04-desktop-ui.sh",
        "config/includes.chroot/etc/os-release",
        "config/includes.chroot/etc/motd",
        "config/includes.chroot/etc/sysctl.d/99-zisha-os-hardening.conf",
        "config/includes.chroot/usr/local/bin/zisha-ai-setup",
        "config/includes.chroot/usr/local/bin/zisha-security-audit",
        "config/includes.chroot/usr/local/bin/zisha-bangla-converter",
        "config/includes.chroot/usr/share/zisha-os/bangla-converter/index.html",
        "config/includes.chroot/usr/share/zisha-os/control-center/index.html",
        "README.md"
    )

    $AllPassed = $true
    foreach ($File in $RequiredFiles) {
        $FullPath = Join-Path $ProjectRoot $File
        if (Test-Path $FullPath) {
            Write-Host "  [OK] $File" -ForegroundColor Green
        } else {
            Write-Host "  [MISSING] $File" -ForegroundColor Red
            $AllPassed = $false
        }
    }

    if ($AllPassed) {
        Write-Host ""
        Write-Host "[SUCCESS] All 18 Zisha OS 1.0 modules, cloud builders, and apps are ready!" -ForegroundColor Green
    } else {
        Write-Error "Some required Zisha OS files are missing."
    }
}

function Invoke-SyncProjectFolder {
    Write-ZishaBanner
    Write-Host "[*] Syncing project to: $TargetZishaFolder ..." -ForegroundColor Yellow
    if (-not (Test-Path $TargetZishaFolder)) {
        New-Item -ItemType Directory -Path $TargetZishaFolder -Force | Out-Null
    }
    Copy-Item -Path "$ProjectRoot\*" -Destination $TargetZishaFolder -Recurse -Force
    Write-Host "[SUCCESS] Project mirrored to: $TargetZishaFolder" -ForegroundColor Green
}

function Invoke-OpenControlCenter {
    Write-ZishaBanner
    $ControlHtml = Join-Path $ProjectRoot "config\includes.chroot\usr\share\zisha-os\control-center\index.html"
    if (Test-Path $ControlHtml) {
        Write-Host "[*] Opening Zisha OS 1.0 Master Control Center..." -ForegroundColor Green
        Start-Process $ControlHtml
    } else {
        Write-Error "Control Center HTML not found at $ControlHtml"
    }
}

function Invoke-OpenBanglaConverter {
    Write-ZishaBanner
    $ConverterHtml = Join-Path $ProjectRoot "config\includes.chroot\usr\share\zisha-os\bangla-converter\index.html"
    if (Test-Path $ConverterHtml) {
        Write-Host "[*] Opening Zisha OS Offline Bangla Converter (Unicode <-> Bijoy)..." -ForegroundColor Green
        Start-Process $ConverterHtml
    } else {
        Write-Error "Converter HTML not found at $ConverterHtml"
    }
}

function Invoke-BuildISO {
    Write-ZishaBanner
    Write-Host "[*] Checking local ISO build prerequisites on your HP 13th Gen Intel Core i3-1315U..." -ForegroundColor Yellow

    $OutputDir = Join-Path $ProjectRoot "output"
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }

    if (Get-Command docker -ErrorAction SilentlyContinue) {
        Write-Host "[*] Docker detected. Building Zisha OS ISO Builder image..." -ForegroundColor Cyan
        docker build -t zisha-os-builder:1.0 -f "$ProjectRoot\Dockerfile.isobuilder" $ProjectRoot
        docker run --rm --privileged -v "${ProjectRoot}:/workspace" zisha-os-builder:1.0
    }
    elseif ((Get-Command wsl -ErrorAction SilentlyContinue) -and ((wsl --status 2>$null) -ne $null)) {
        Write-Host "[*] WSL2 detected. Building Zisha OS ISO..." -ForegroundColor Cyan
        $WslPath = wsl wslpath -a ($ProjectRoot -replace '\\', '/')
        wsl -u root bash -c "cd '$WslPath' && bash scripts/build-iso.sh"
    }
    else {
        Write-Host "[!] Notice: Virtualization (VT-x) / WSL2 / Docker is not enabled yet on this HP laptop." -ForegroundColor Yellow
        Write-Host "    Opening Zisha OS Master Control Center with the 3 easy ISO & Install methods..." -ForegroundColor Cyan
        Invoke-OpenControlCenter
    }
}

switch ($Action) {
    "Validate"            { Invoke-Validate }
    "BuildISO"            { Invoke-BuildISO }
    "OpenControlCenter"   { Invoke-OpenControlCenter }
    "OpenBanglaConverter" { Invoke-OpenBanglaConverter }
    "SyncProjectFolder"   { Invoke-SyncProjectFolder }
}
