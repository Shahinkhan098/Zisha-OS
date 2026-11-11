#!/usr/bin/env bash
# ==============================================================================
# Zisha OS 1.0 — Module 04: Fast, Modern XFCE4 Desktop UI & Zisha OS Branding
# ==============================================================================
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[Zisha OS] ===> Installing Lightweight & Modern XFCE4 Desktop Environment..."

apt-get update
apt-get install -y --no-install-recommends \
    xorg \
    xfce4 \
    xfce4-goodies \
    xfce4-whiskermenu-plugin \
    xfce4-terminal \
    xfce4-power-manager \
    xfce4-screenshooter \
    lightdm \
    lightdm-gtk-greeter \
    network-manager-gnome \
    pavucontrol \
    pulseaudio \
    papirus-icon-theme \
    arc-theme \
    thunar \
    thunar-archive-plugin \
    file-roller \
    firefox-esr \
    calamares \
    calamares-settings-debian

# ------------------------------------------------------------------------------
# 0. Install Google Chrome Stable & Set as Default System Web Browser
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Installing Google Chrome Stable as Default Browser..."
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
    | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg || true

if [ -f /usr/share/keyrings/google-chrome.gpg ]; then
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list
    apt-get update && apt-get install -y --no-install-recommends google-chrome-stable || true
fi

if command -v google-chrome-stable >/dev/null 2>&1; then
    update-alternatives --set x-www-browser /usr/bin/google-chrome-stable || true
    update-alternatives --set gnome-www-browser /usr/bin/google-chrome-stable || true
fi

mkdir -p /etc/xdg/xfce4 /etc/xdg
cat > /etc/xdg/xfce4/helpers.rc << 'EOF'
WebBrowser=google-chrome
EOF

cat > /etc/xdg/mimeapps.list << 'EOF'
[Default Applications]
text/html=google-chrome.desktop
x-scheme-handler/http=google-chrome.desktop
x-scheme-handler/https=google-chrome.desktop
x-scheme-handler/about=google-chrome.desktop
x-scheme-handler/unknown=google-chrome.desktop
EOF

# ------------------------------------------------------------------------------
# 1. Create Desktop Application Shortcuts (.desktop files) for Zisha OS Tools
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Creating Zisha OS Application Launchers..."
mkdir -p /usr/share/applications /etc/skel/Desktop

# Launcher 1: Zisha Bangla Converter (Offline Unicode <-> Bijoy)
cat > /usr/share/applications/zisha-bangla-converter.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Zisha Bangla Converter (ইউনিকোড ⇄ বিজয়)
Comment=Offline Bangla Unicode (Avro/Nikosh) to Bijoy (ANSI/SutonnyMJ) Converter & Notepad
Exec=/usr/local/bin/zisha-bangla-converter
Icon=accessories-character-map
Terminal=false
Categories=Office;Utility;
Keywords=Bangla;Bijoy;Avro;Unicode;Nikosh;Converter;
EOF

# Launcher 2: Zisha AI Studio Setup (CPU Optimized)
cat > /usr/share/applications/zisha-ai-setup.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Zisha AI Studio Setup (CPU AI)
Comment=Setup and manage CPU-optimized Local LLMs (Ollama) and Python AI Workspace
Exec=xfce4-terminal -e "/usr/local/bin/zisha-ai-setup"
Icon=utilities-terminal
Terminal=false
Categories=Development;Science;ArtificialIntelligence;
Keywords=AI;LLM;Ollama;PyTorch;Zisha;
EOF

# Launcher 3: Zisha Security Audit
cat > /usr/share/applications/zisha-security-audit.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Zisha Security & Privacy Audit
Comment=Verify Firewall, Localhost Isolation, AppArmor, zram, and Git Secret Protection
Exec=xfce4-terminal --hold -e "/usr/local/bin/zisha-security-audit"
Icon=security-high
Terminal=false
Categories=System;Security;
Keywords=Security;Firewall;Audit;Zisha;
EOF

# Launcher 4: Google Antigravity Setup (IDE & CLI)
cat > /usr/share/applications/zisha-install-antigravity.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Install Google Antigravity (IDE & CLI)
Comment=One-click installer for Google Antigravity IDE and agy CLI on Zisha OS
Exec=xfce4-terminal --hold -e "/usr/local/bin/zisha-install-antigravity"
Icon=applications-development
Terminal=false
Categories=Development;IDE;
Keywords=Antigravity;AGY;Google;AI;IDE;Zisha;
EOF

cp /usr/share/applications/zisha-bangla-converter.desktop /etc/skel/Desktop/
cp /usr/share/applications/zisha-ai-setup.desktop /etc/skel/Desktop/
cp /usr/share/applications/zisha-security-audit.desktop /etc/skel/Desktop/
cp /usr/share/applications/zisha-install-antigravity.desktop /etc/skel/Desktop/
if [ -f /usr/share/applications/google-chrome.desktop ]; then
    cp /usr/share/applications/google-chrome.desktop /etc/skel/Desktop/
fi
chmod +x /etc/skel/Desktop/*.desktop

# ------------------------------------------------------------------------------
# 2. Autostart IBus Keyboard Tray (English / Avro / Bijoy Switcher) on Login
# ------------------------------------------------------------------------------
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/zisha-ibus-autostart.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Zisha OS Bangla/English Keyboard (IBus)
Comment=Starts IBus for instant English, Avro Phonetic, and Bijoy switching
Exec=ibus-daemon -drx
OnlyShowIn=XFCE;GNOME;KDE;LXQt;
StartupNotify=false
Terminal=false
EOF

# ------------------------------------------------------------------------------
# 3. Configure Default Skeleton Workspace for New Users
# ------------------------------------------------------------------------------
mkdir -p /etc/skel/Projects/web-dev
mkdir -p /etc/skel/Projects/ai-engineering
mkdir -p /etc/skel/Office-Documents/Bangla-Official
mkdir -p /etc/skel/Office-Documents/English-Official

cp -r /etc/zisha-os/ai-template/* /etc/skel/Projects/ai-engineering/ || true

echo "[Zisha OS] ===> Module 04 (Desktop UI & Branding) Completed Successfully."
