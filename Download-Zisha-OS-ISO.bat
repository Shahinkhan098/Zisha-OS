@echo off
title Zisha OS 1.0 - Direct ISO Downloader
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Download-Zisha-OS-ISO.ps1"
pause
