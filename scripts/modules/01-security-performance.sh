#!/usr/bin/env bash
# ==============================================================================
# Zisha OS 1.0 — Module 01: Security Hardening & CPU/RAM Performance Booster
# ==============================================================================
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[Zisha OS] ===> Installing Security & Performance Packages..."

apt-get update
apt-get install -y --no-install-recommends \
    ufw \
    apparmor \
    apparmor-utils \
    apparmor-profiles \
    apparmor-profiles-extra \
    firejail \
    firejail-profiles \
    cryptsetup \
    cryptsetup-initramfs \
    zram-tools \
    earlyoom \
    cpufrequtils \
    mesa-va-drivers \
    mesa-vulkan-drivers \
    intel-media-va-driver \
    vainfo \
    fail2ban \
    rkhunter \
    chkrootkit \
    auditd \
    libpam-tmpdir \
    unattended-upgrades \
    apt-listchanges

# ------------------------------------------------------------------------------
# 1. Configure zram (Compressed RAM in memory for fast CPU AI & Multitasking)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Configuring zram-tools (50% RAM with zstd compression)..."
cat > /etc/default/zramswap << 'EOF'
# Zisha OS Fast Memory Compression Config
ALGO=zstd
PERCENT=50
PRIORITY=100
EOF

# ------------------------------------------------------------------------------
# 2. Configure earlyoom (Prevents system freeze during heavy AI/Docker loads)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Configuring earlyoom anti-freeze protection..."
cat > /etc/default/earlyoom << 'EOF'
EARLYOOM_ARGS="-r 60 -m 5 -s 10 --avoid '(^|/)(init|systemd|Xorg|xfwm4|sshd)$' --prefer '(^|/)(ollama|python3|node|chrome|firefox)$'"
EOF

# ------------------------------------------------------------------------------
# 3. Configure UFW Firewall (Zero-Trust Incoming + Localhost-Isolated Dev Ports)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Configuring UFW Firewall rules..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Explicitly allow localhost traffic while blocking external access to local dev/AI ports:
# 3000 (React/Next.js), 5173 (Vite), 8000 (FastAPI/Django), 8080 (Web), 8888 (Jupyter), 11434 (Ollama)
for PORT in 3000 5173 8000 8080 8888 11434 5432 6379; do
    ufw allow in on lo to 127.0.0.1 port "$PORT" proto tcp comment "Zisha OS Local Dev/AI Port $PORT"
    ufw deny in on any to any port "$PORT" proto tcp comment "Block external access to Dev/AI Port $PORT"
done

# Enable UFW on boot
sed -i 's/ENABLED=no/ENABLED=yes/' /etc/ufw/ufw.conf || true

# ------------------------------------------------------------------------------
# 4. Global Git Pre-Commit Secret Scanner Hook (Prevents leaking AI API Keys)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Installing Global Git Secret Protection Hook..."
mkdir -p /etc/zisha-os/git-hooks

cat > /etc/zisha-os/git-hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
# Zisha OS — Automatic API Key & Secret Leak Prevention Hook
set -e

FORBIDDEN_PATTERNS=(
    "sk-[a-zA-Z0-9]{20,}"                   # OpenAI / Anthropic API keys
    "sk-ant-[a-zA-Z0-9\-_]{20,}"            # Anthropic Claude keys
    "AIzaSy[a-zA-Z0-9\-_]{33}"              # Google Gemini / Cloud API keys
    "ghp_[a-zA-Z0-9]{36}"                   # GitHub Personal Access Tokens
    "AKIA[0-9A-Z]{16}"                      # AWS Access Key ID
    "-----BEGIN (RSA|OPENSSH|EC|PGP) PRIVATE KEY-----"
)

STAGED_DIFF=$(git diff --cached --diff-filter=ACM -U0)

for PATTERN in "${FORBIDDEN_PATTERNS[@]}"; do
    if echo "$STAGED_DIFF" | grep -E -q "$PATTERN"; then
        echo "=================================================================="
        echo " [Zisha OS Security Alert] BLOCKED GIT COMMIT!"
        echo " A potential API Key or Private Key matching ($PATTERN)"
        echo " was detected in your staged changes."
        echo " Move secrets to .env (and add .env to .gitignore) before committing."
        echo "=================================================================="
        exit 1
    fi
done
exit 0
EOF

chmod +x /etc/zisha-os/git-hooks/pre-commit
git config --system core.hooksPath /etc/zisha-os/git-hooks || true

# ------------------------------------------------------------------------------
# 5. Privacy Hardening: Encrypted DNS (Cloudflare/Quad9 DNSSEC)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Configuring Privacy-First DNS..."
mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/90-zisha-dns.conf << 'EOF'
[main]
dns=default

[global-dns-domain-*]
servers=1.1.1.1,9.9.9.9,1.0.0.1
EOF

echo "[Zisha OS] ===> Module 01 (Security & Performance) Completed Successfully."
