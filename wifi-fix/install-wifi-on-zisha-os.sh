#!/usr/bin/env bash
# ==============================================================================
# Zisha OS 1.0 — 1-Click Wi-Fi Firmware & NetworkManager Fixer
# Works both OFFLINE (from pre-downloaded .deb files) and ONLINE (via USB Tethering)
# ==============================================================================
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}======================================================================${NC}"
echo -e "${GREEN}   Zisha OS 1.0 — Wi-Fi Driver & Connection Fixer${NC}"
echo -e "${CYAN}======================================================================${NC}"

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}Please run with sudo: sudo bash $0${NC}"
    exit 1
fi

# 1. Unblock Wi-Fi if blocked by rfkill
if command -v rfkill >/dev/null 2>&1; then
    rfkill unblock all || true
fi

# 2. Install Offline .deb Firmware Packages if present in this folder
if ls "$SCRIPT_DIR"/*.deb >/dev/null 2>&1; then
    echo -e "${CYAN}[1/3] Installing Offline Wi-Fi Firmware (.deb packages)...${NC}"
    dpkg -i "$SCRIPT_DIR"/*.deb || true
fi

# 3. Also check if internet is available (e.g. via Mobile USB Tethering) and install via apt
if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo -e "${CYAN}[2/3] Internet detected! Installing complete Wi-Fi firmware via APT...${NC}"
    sed -i 's/main$/main contrib non-free non-free-firmware/g' /etc/apt/sources.list || true
    apt-get update
    apt-get install -y firmware-realtek firmware-iwlwifi firmware-atheros firmware-misc-nonfree network-manager network-manager-gnome wpasupplicant
fi

# 4. Reload Wi-Fi Kernel Modules & Restart NetworkManager
echo -e "${CYAN}[3/3] Reloading Wi-Fi Drivers & Starting NetworkManager...${NC}"
modprobe -r rtw89_8852be rtw89_8852ae rtw89_8852ce rtw88_8821ce rtw88_8822ce iwlwifi mt7921e 2>/dev/null || true
modprobe rtw89_8852be 2>/dev/null || true
modprobe rtw89_8852ce 2>/dev/null || true
modprobe rtw88_8821ce 2>/dev/null || true
modprobe iwlwifi 2>/dev/null || true
modprobe mt7921e 2>/dev/null || true

systemctl enable NetworkManager || true
systemctl restart NetworkManager || true
nmcli networking on || true
nmcli radio wifi on || true

echo ""
echo -e "${GREEN}======================================================================${NC}"
echo -e "${GREEN} [SUCCESS] Wi-Fi Drivers Loaded & NetworkManager Restarted!${NC}"
echo -e "  -> To connect via Terminal UI, run: ${YELLOW}nmtui${NC}"
echo -e "  -> Or click the Network icon in the bottom-right taskbar!"
echo -e "${GREEN}======================================================================${NC}"
