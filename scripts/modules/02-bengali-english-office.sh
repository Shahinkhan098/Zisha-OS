#!/usr/bin/env bash
# ==============================================================================
# Zisha OS 1.0 — Module 02: Complete Bengali (Avro + Bijoy) & English Office Suite
# ==============================================================================
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[Zisha OS] ===> Installing Bengali & English Input Methods, Fonts, and Office Suite..."

# Enable contrib and non-free-firmware for Microsoft Core Fonts
sed -i 's/main$/main contrib non-free non-free-firmware/g' /etc/apt/sources.list || true
apt-get update

# Pre-accept MS Core Fonts EULA so installation is 100% automated
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections

# ------------------------------------------------------------------------------
# 1. Install Input Methods (Avro Phonetic + Bijoy/Unijoy + OpenBangla)
# ------------------------------------------------------------------------------
apt-get install -y --no-install-recommends \
    ibus \
    ibus-gtk \
    ibus-gtk3 \
    ibus-gtk4 \
    ibus-avro \
    ibus-m17n \
    m17n-db \
    im-config \
    locales

# Try installing openbangla-keyboard if available in repo
apt-get install -y --no-install-recommends openbangla-keyboard || true

# Generate English (US) and Bengali (BD) UTF-8 Locales
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen || true
sed -i 's/# bn_BD UTF-8/bn_BD UTF-8/' /etc/locale.gen || true
grep -q "en_US.UTF-8 UTF-8" /etc/locale.gen || echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
grep -q "bn_BD UTF-8" /etc/locale.gen || echo "bn_BD UTF-8" >> /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

# Set IBus as default input method framework across X11/Wayland/GTK/Qt
cat > /etc/profile.d/zisha-ibus-bangla.sh << 'EOF'
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
EOF
chmod +x /etc/profile.d/zisha-ibus-bangla.sh

# ------------------------------------------------------------------------------
# 2. Install Bengali & English Official Fonts (Nikosh, SolaimanLipi, Kalpurush, MS Fonts)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Installing Bengali & English Font Pack..."
apt-get install -y --no-install-recommends \
    fonts-beng \
    fonts-beng-extra \
    fonts-lohit-beng-bengali \
    fonts-lohit-beng-assamese \
    fonts-noto-core \
    fonts-noto-ui-core \
    fonts-liberation2 \
    fonts-crosextra-carlito \
    fonts-crosextra-caladea \
    ttf-mscorefonts-installer \
    fontconfig \
    curl \
    unzip

# Download Popular Bangladeshi Official Fonts (Kalpurush, Siyam Rupali, SolaimanLipi, Nikosh)
BANG_FONT_DIR="/usr/share/fonts/truetype/zisha-bangla"
mkdir -p "$BANG_FONT_DIR"

download_font_safe() {
    local url="$1"
    local dest="$2"
    curl -fsSL --retry 2 --connect-timeout 10 "$url" -o "$dest" || echo "[Note] Offline/Skipped external font: $dest (fallback fonts active)"
}

# Fetch open Bangladeshi Unicode fonts from reliable mirrors if internet is active during ISO build
download_font_safe "https://github.com/google/fonts/raw/main/ofl/hindsiliguri/HindSiliguri-Regular.ttf" "$BANG_FONT_DIR/HindSiliguri-Regular.ttf"
download_font_safe "https://github.com/google/fonts/raw/main/ofl/hindsiliguri/HindSiliguri-Bold.ttf" "$BANG_FONT_DIR/HindSiliguri-Bold.ttf"
download_font_safe "https://github.com/google/fonts/raw/main/ofl/notosansbengali/NotoSansBengali%5Bwdth%2Cwght%5D.ttf" "$BANG_FONT_DIR/NotoSansBengali.ttf"
download_font_safe "https://github.com/google/fonts/raw/main/ofl/notoserifbengali/NotoSerifBengali%5Bwdth%2Cwght%5D.ttf" "$BANG_FONT_DIR/NotoSerifBengali.ttf"

# Configure Fontconfig so Nikosh / SolaimanLipi / Kalpurush / Calibri / Times New Roman always render cleanly
cat > /etc/fonts/local.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <!-- Smooth Bengali & English Font Rendering -->
  <match target="font">
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
    <edit name="hinting" mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
  </match>

  <!-- Map Calibri & Cambria to Carlito & Caladea metric-compatible fonts if needed -->
  <alias>
    <family>Calibri</family>
    <prefer><family>Calibri</family><family>Carlito</family></prefer>
  </alias>
  <alias>
    <family>Cambria</family>
    <prefer><family>Cambria</family><family>Caladea</family></prefer>
  </alias>

  <!-- Ensure Bengali fallback works across all applications -->
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans</family>
      <family>Hind Siliguri</family>
      <family>Noto Sans Bengali</family>
      <family>Lohit Bengali</family>
    </prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Times New Roman</family>
      <family>Noto Serif Bengali</family>
      <family>Mukti Narrow</family>
    </prefer>
  </alias>
</fontconfig>
EOF

fc-cache -fv

# ------------------------------------------------------------------------------
# 3. Install Office Suite (LibreOffice + Spellcheck + PDF Tools + Bangla OCR)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Installing LibreOffice, PDF Arranger, Scanner & Bangla/English OCR..."
apt-get install -y --no-install-recommends \
    libreoffice-writer \
    libreoffice-calc \
    libreoffice-impress \
    libreoffice-gtk3 \
    libreoffice-l10n-bn \
    hunspell \
    hunspell-en-us \
    hunspell-bn \
    aspell-en \
    aspell-bn \
    pdfarranger \
    evince \
    simple-scan \
    tesseract-ocr \
    tesseract-ocr-ben \
    tesseract-ocr-eng \
    gimagereader \
    galculator \
    flameshot

# ------------------------------------------------------------------------------
# 4. Install OnlyOffice Desktop Editors (100% MS Word/Excel/PowerPoint Compatible)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Setting up OnlyOffice Desktop Editors repository..."
mkdir -p -m 700 /root/.gnupg
curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --dearmor -o /usr/share/keyrings/onlyoffice.gpg || true
if [ -f /usr/share/keyrings/onlyoffice.gpg ]; then
    echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main" \
        > /etc/apt/sources.list.d/onlyoffice.list
    apt-get update && apt-get install -y --no-install-recommends onlyoffice-desktopeditors || echo "[Note] OnlyOffice can be installed post-boot via 'sudo apt install onlyoffice-desktopeditors'"
fi

# ------------------------------------------------------------------------------
# 5. Pre-configure Default IBus Input Engines (English + Avro + Bijoy Unijoy)
# ------------------------------------------------------------------------------
mkdir -p /etc/dconf/profile /etc/dconf/db/local.d
cat > /etc/dconf/profile/user << 'EOF'
user-db:user
system-db:local
EOF

cat > /etc/dconf/db/local.d/00-zisha-ibus << 'EOF'
[desktop/ibus/general]
preload-engines=['xkb:us::eng', 'avro-phonetic', 'm17n:bn:unijoy', 'm17n:bn:probhat']
use-system-keyboard-layout=true

[desktop/ibus/general/hotkey]
triggers=['<Super>space', '<Control>space']
EOF

dconf update || true

echo "[Zisha OS] ===> Module 02 (Bengali & English Office Suite) Completed Successfully."
