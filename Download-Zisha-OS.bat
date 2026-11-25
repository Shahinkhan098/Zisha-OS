@echo off
title Zisha OS 1.0 - Resumable ISO Downloader (3.5 GB)
cd /d "%~dp0"
echo ======================================================================
echo    Starting Zisha OS 1.0 Safe Resumable Downloader (3.5 GB)
echo    Auto-resume enabled: Never stops midway on internet drops!
echo ======================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Download-Zisha-OS-Resumable.ps1"
pause
