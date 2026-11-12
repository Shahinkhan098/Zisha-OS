#!/usr/bin/env bash
# ==============================================================================
# Zisha OS 1.0 — Master Bootable ISO Builder (Debian 12 Live-Build Engine)
# Equipped with: Modern Backports Linux Kernel (6.6+) & Realtek RTL8852BE Wi-Fi 6
# Generates: /workspace/output/zisha-os-1.0-amd64.iso
# ==============================================================================
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="/tmp/zisha-os-livebuild"
OUTPUT_DIR="${PROJECT_ROOT}/output"
ISO_FILENAME="zisha-os-1.0-amd64.iso"

mkdir -p "$OUTPUT_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "======================================================================"
echo "   Building Zisha OS 1.0 (Hardened Security, Realtek Wi-Fi & AI Edition)"
echo "   Working Directory : $BUILD_DIR"
echo "   Target ISO Output : ${OUTPUT_DIR}/${ISO_FILENAME}"
echo "======================================================================"

# 1. Initialize Debian 12 (Bookworm) Live-Build Configuration
lb config noauto \
    --architectures amd64 \
    --distribution bookworm \
    --debian-installer live \
    --debian-installer-gui true \
    --archive-areas "main contrib non-free non-free-firmware" \
    --backports true \
    --bootappend-live "boot=live components quiet splash hostname=zisha-os username=zisha locales=en_US.UTF-8,bn_BD.UTF-8 keyboard-layouts=us pci=noaer" \
    --iso-application "Zisha OS 1.0" \
    --iso-preparer "Zisha OS Builder" \
    --iso-publisher "Zisha OS Project" \
    --iso-volume "ZISHA_OS_1_0" \
    --security true \
    --updates true

# 2. Configure Debian Backports Archive & APT Pinning for Kernel 6.6+ and RTL8852BE Wi-Fi
mkdir -p config/archives
cat > config/archives/backports.list.chroot << 'EOF'
deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
EOF

cat > config/archives/backports.pref.chroot << 'EOF'
Package: linux-image-amd64 linux-headers-amd64 firmware-realtek firmware-misc-nonfree firmware-iwlwifi
Pin: release a=bookworm-backports
Pin-Priority: 990
EOF

# 3. Copy Custom Chroot Files (Branding, Sysctl Hardening, Utilities, Modprobe Wi-Fi)
mkdir -p config/includes.chroot
cp -r "${PROJECT_ROOT}/config/includes.chroot/"* config/includes.chroot/
chmod +x config/includes.chroot/usr/local/bin/*

# 4. Copy the 4 Core Provisioning Modules as Live-Build Chroot Hooks
mkdir -p config/hooks/normal
cp "${PROJECT_ROOT}/scripts/modules/01-security-performance.sh" config/hooks/normal/0100-security-performance.hook.chroot
cp "${PROJECT_ROOT}/scripts/modules/02-bengali-english-office.sh" config/hooks/normal/0200-bengali-english-office.hook.chroot
cp "${PROJECT_ROOT}/scripts/modules/03-webdev-ai-stack.sh" config/hooks/normal/0300-webdev-ai-stack.hook.chroot
cp "${PROJECT_ROOT}/scripts/modules/04-desktop-ui.sh" config/hooks/normal/0400-desktop-ui.hook.chroot
chmod +x config/hooks/normal/*.hook.chroot

# 5. Core Live-Boot Packages with Full Modern Wi-Fi & Firmware
mkdir -p config/package-lists
cat > config/package-lists/zisha-core.list.chroot << 'EOF'
live-boot
live-config
live-config-systemd
systemd-sysv
sudo
network-manager
network-manager-gnome
wpasupplicant
wireless-tools
wireless-regdb
iw
rfkill
linux-image-amd64
linux-headers-amd64
firmware-linux
firmware-linux-nonfree
firmware-misc-nonfree
firmware-iwlwifi
firmware-realtek
firmware-atheros
firmware-brcm80211
cryptsetup
lvm2
EOF

# 6. Execute the ISO Build
echo "[Zisha OS] ===> Running 'lb build' to assemble squashfs and bootable ISO..."
lb build

# 7. Export Final ISO to Project Output Folder
if [ -f "live-image-amd64.hybrid.iso" ]; then
    mv "live-image-amd64.hybrid.iso" "${OUTPUT_DIR}/${ISO_FILENAME}"
    sha256sum "${OUTPUT_DIR}/${ISO_FILENAME}" > "${OUTPUT_DIR}/${ISO_FILENAME}.sha256"
    echo "======================================================================"
    echo " [SUCCESS] Zisha OS 1.0 ISO Built Successfully!"
    echo " File     : ${OUTPUT_DIR}/${ISO_FILENAME}"
    echo " Checksum : ${OUTPUT_DIR}/${ISO_FILENAME}.sha256"
    echo "======================================================================"
else
    echo "[ERROR] ISO file was not generated. Check build.log for details."
    exit 1
fi
