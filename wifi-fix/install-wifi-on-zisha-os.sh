#!/usr/bin/env bash
# ==============================================================================
# Zisha OS 1.0 — 1-Click Wi-Fi Firmware & NetworkManager Fixer
# Tailored for: Realtek RTL8852BE / RTL8852CE & Intel Wi-Fi 6
# Works both OFFLINE (from pre-downloaded .deb files) and ONLINE (via USB Tethering)
# ==============================================================================
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}======================================================================${NC}"
echo -e "${GREEN}   Zisha OS 1.0 — Realtek RTL8852BE & Wi-Fi Driver Fixer${NC}"
echo -e "${CYAN}======================================================================${NC}"

if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}Please run with sudo: sudo bash $0${NC}"
    exit 1
fi

# 1. Unblock Wi-Fi if blocked by rfkill
if command -v rfkill >/dev/null 2>&1; then
    rfkill unblock all || true
fi

# 2. Configure Realtek PCIe ASPM fix so card does not sleep prematurely on HP laptops
mkdir -p /etc/modprobe.d
cat > /etc/modprobe.d/rtw89.conf << 'EOF'
options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y
options rtw89_core disable_lps_deep=y
EOF

# 3. Ensure NetworkManager manages all devices
mkdir -p /etc/NetworkManager
cat > /etc/NetworkManager/NetworkManager.conf << 'EOF'
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=yes
EOF

# 4. Install Offline .deb Firmware Packages if present in this folder
if ls "$SCRIPT_DIR"/*.deb >/dev/null 2>&1; then
    echo -e "${CYAN}[1/3] Installing Offline Wi-Fi Firmware (.deb packages)...${NC}"
    dpkg -i "$SCRIPT_DIR"/*.deb || true
fi

# 5. If internet is active (e.g. via Mobile USB Tethering), upgrade to modern Backports Kernel & Firmware
if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo -e "${CYAN}[2/3] Internet detected! Installing Debian Backports Kernel 6.6+ & Realtek Firmware...${NC}"
    echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" > /etc/apt/sources.list.d/backports.list
    sed -i 's/main$/main contrib non-free non-free-firmware/g' /etc/apt/sources.list || true
    apt-get update
    apt-get install -y -t bookworm-backports linux-image-amd64 linux-headers-amd64 firmware-realtek firmware-misc-nonfree firmware-iwlwifi || true
    apt-get install -y network-manager network-manager-gnome wpasupplicant wireless-regdb iw rfkill
fi

# 6. Reload Wi-Fi Kernel Modules & Restart NetworkManager
echo -e "${CYAN}[3/3] Reloading Realtek RTL8852BE Wi-Fi Driver...${NC}"
modprobe -r rtw89_8852be rtw89_8852ce rtw88_8821ce iwlwifi mt7921e 2>/dev/null || true
modprobe rtw89_8852be 2>/dev/null || true
modprobe rtw89_8852ce 2>/dev/null || true

systemctl enable NetworkManager || true
systemctl restart NetworkManager || true
nmcli networking on || true
nmcli radio wifi on || true

echo ""
echo -e "${GREEN}======================================================================${NC}"
echo -e "${GREEN} [SUCCESS] Realtek RTL8852BE Driver Configured & NetworkManager Restarted!${NC}"
echo -e "  -> To connect to Wi-Fi via UI, run: ${YELLOW}nmtui${NC}"
echo -e "  -> Or click the Wi-Fi icon in the bottom-right taskbar!"
echo -e "${GREEN}======================================================================${NC}"
