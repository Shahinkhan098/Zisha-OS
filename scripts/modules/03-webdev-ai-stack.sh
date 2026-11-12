#!/usr/bin/env bash
# ==============================================================================
# Zisha OS 1.0 — Module 03: Web/Software Development & CPU-Optimized AI Stack
# ==============================================================================
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[Zisha OS] ===> Installing Web & Software Development Stack..."

apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    cmake \
    git \
    curl \
    wget \
    ca-certificates \
    gnupg \
    jq \
    ripgrep \
    fd-find \
    fzf \
    tmux \
    zsh \
    htop \
    btop \
    neovim \
    unzip \
    zip \
    tar \
    xz-utils \
    sqlite3 \
    libsqlite3-dev \
    postgresql-client \
    redis-tools \
    python3 \
    python3-venv \
    python3-pip \
    python3-dev \
    docker.io \
    docker-compose \
    nodejs \
    npm

# ------------------------------------------------------------------------------
# 1. Configure Docker Daemon with Log Rotation & Security Best Practices
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Configuring Docker Engine with automatic log limits..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "20m",
    "max-file": "3"
  },
  "live-restore": true,
  "no-new-privileges": false
}
EOF

# ------------------------------------------------------------------------------
# 2. Install Fast JS/TS Tooling (pnpm, Bun) & Python Package Manager (uv)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Installing pnpm, Bun & uv (Ultra-Fast Python Package Manager)..."
npm install -g pnpm || true

# Install Bun globally
curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash || true

# Install uv globally to /usr/local/bin
curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh || true

# ------------------------------------------------------------------------------
# 2.1 Install GitHub CLI (gh), Bruno (API Client) & Beekeeper Studio (DB GUI)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Setting up GitHub CLI, Bruno & Beekeeper Studio..."
# GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null || true
if [ -f /usr/share/keyrings/githubcli-archive-keyring.gpg ]; then
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
    apt-get update && apt-get install -y --no-install-recommends gh || true
fi

# Bruno (Lightweight, Offline Postman Alternative)
mkdir -p /etc/apt/keyrings
gpg --no-default-keyring --keyring /etc/apt/keyrings/bruno.gpg --keyserver keyserver.ubuntu.com --recv-keys 9FA6017ECABE0266 2>/dev/null || true
if [ -f /etc/apt/keyrings/bruno.gpg ]; then
    echo "deb [signed-by=/etc/apt/keyrings/bruno.gpg] http://debian.usebruno.com/ bruno stable" > /etc/apt/sources.list.d/bruno.list
    apt-get update && apt-get install -y --no-install-recommends bruno || true
fi

# Beekeeper Studio (Clean, Lightweight Database GUI for PostgreSQL/MySQL/SQLite)
curl -fsSL https://deb.beekeeperstudio.io/beekeeper.key | gpg --dearmor --yes -o /usr/share/keyrings/beekeeper.gpg || true
if [ -f /usr/share/keyrings/beekeeper.gpg ]; then
    echo "deb [signed-by=/usr/share/keyrings/beekeeper.gpg] https://deb.beekeeperstudio.io stable main" > /etc/apt/sources.list.d/beekeeper-studio-app.list
    apt-get update && apt-get install -y --no-install-recommends beekeeper-studio || true
fi

# ------------------------------------------------------------------------------
# 3. Install VSCodium (Telemetry-Free Open Source VS Code)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Setting up VSCodium Code Editor repository..."
curl -fsSL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor -o /usr/share/keyrings/vscodium-archive-keyring.gpg || true

if [ -f /usr/share/keyrings/vscodium-archive-keyring.gpg ]; then
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
        > /etc/apt/sources.list.d/vscodium.list
    apt-get update && apt-get install -y --no-install-recommends codium || true
fi

# ------------------------------------------------------------------------------
# 4. CPU-Optimized AI Stack Configuration (No Dedicated GPU Required)
# ------------------------------------------------------------------------------
echo "[Zisha OS] ===> Configuring CPU-Optimized AI Environment..."
mkdir -p /etc/zisha-os/ai-template

# Create a ready-to-use requirements-cpu.txt that specifically pulls lightweight CPU-only PyTorch
cat > /etc/zisha-os/ai-template/requirements-cpu.txt << 'EOF'
--extra-index-url https://download.pytorch.org/whl/cpu
torch
torchvision
torchaudio
numpy
pandas
scikit-learn
fastapi
uvicorn[standard]
pydantic
langchain
langchain-community
langgraph
chromadb
openai
anthropic
google-genai
jupyterlab
streamlit
python-dotenv
httpx
EOF

# Create a starter FastAPI + Local/Cloud AI Agent boilerplate in /etc/zisha-os/ai-template
cat > /etc/zisha-os/ai-template/main_ai_agent.py << 'EOF'
"""
Zisha OS 1.0 — Starter AI Engineer Agent Template (Local Ollama CPU + Cloud API Ready)
Run with: uvicorn main_ai_agent:app --reload --host 127.0.0.1 --port 8000
"""
import os
from fastapi import FastAPI
from pydantic import BaseModel
import httpx

app = FastAPI(title="Zisha OS AI Service", version="1.0.0")

OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://127.0.0.1:11434")
DEFAULT_CPU_MODEL = os.getenv("ZISHA_AI_MODEL", "qwen2.5-coder:1.5b")


class PromptRequest(BaseModel):
    prompt: str
    model: str = DEFAULT_CPU_MODEL


@app.get("/health")
async def health_check():
    return {
        "os": "Zisha OS 1.0",
        "mode": "CPU-Optimized AI Engine",
        "ollama_url": OLLAMA_BASE_URL,
        "default_model": DEFAULT_CPU_MODEL,
    }


@app.post("/chat")
async def chat_local_ai(req: PromptRequest):
    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(
            f"{OLLAMA_BASE_URL}/api/generate",
            json={"model": req.model, "prompt": req.prompt, "stream": False},
        )
        resp.raise_for_status()
        data = resp.json()
        return {"model": req.model, "response": data.get("response", "")}
EOF

# Configure CPU-friendly environment variables for Ollama & PyTorch
cat > /etc/profile.d/zisha-ai-cpu-env.sh << 'EOF'
# Zisha OS — CPU AI Optimization Variables
export OLLAMA_HOST="127.0.0.1:11434"
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_MAX_LOADED_MODELS=1
export OMP_NUM_THREADS=4
export MKL_NUM_THREADS=4
export PIP_NO_CACHE_DIR=off
EOF
chmod +x /etc/profile.d/zisha-ai-cpu-env.sh

echo "[Zisha OS] ===> Module 03 (Web Dev & CPU AI Stack) Completed Successfully."
