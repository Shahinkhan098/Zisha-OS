#!/usr/bin/env bash
# ==============================================================================
# Zisha OS 1.0 — Direct Transformation Installer for Any Debian/Ubuntu System
# Usage: sudo bash scripts/install-on-existing-linux.sh
# ==============================================================================
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root: sudo bash scripts/install-on-existing-linux.sh"
    exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "======================================================================"
echo "   Transforming Current Linux System into Zisha OS 1.0..."
echo "======================================================================"

# 1. Copy Zisha OS Branding, Sysctl Hardening & Built-in Apps
cp -r "${PROJECT_ROOT}/config/includes.chroot/"* /
chmod +x /usr/local/bin/zisha-*
sysctl --system || true

# 2. Run All 4 Zisha OS Modules in Order
bash "${PROJECT_ROOT}/scripts/modules/01-security-performance.sh"
bash "${PROJECT_ROOT}/scripts/modules/02-bengali-english-office.sh"
bash "${PROJECT_ROOT}/scripts/modules/03-webdev-ai-stack.sh"
bash "${PROJECT_ROOT}/scripts/modules/04-desktop-ui.sh"

echo "======================================================================"
echo " [SUCCESS] System Transformed into Zisha OS 1.0!"
echo " Reboot your system to load the Zisha OS Desktop & Hardened Kernel."
echo "======================================================================"
