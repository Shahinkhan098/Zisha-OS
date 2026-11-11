@echo off
title Zisha OS 1.0 - 60 GB Safe Disk Partition Preparation
cd /d "%~dp0"

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [*] Requesting Administrator privileges... Please click "Yes" on the popup.
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\prepare-zisha-disk.ps1" -TargetDrive D -ShrinkGB 60
pause
