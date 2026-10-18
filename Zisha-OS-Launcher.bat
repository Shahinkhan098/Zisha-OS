@echo off
title Zisha OS 1.0 - Master Launcher
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File ".\build-zisha-os.ps1" -Action OpenControlCenter
