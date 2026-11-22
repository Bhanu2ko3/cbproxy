#!/bin/bash
# ==============================================================================
# :: CodebroAI cbproxy // Native Linux CLI Installer ::
# ==============================================================================

set -e

if [[ -n "${BASH_SOURCE[0]}" && -f "${BASH_SOURCE[0]}" ]]; then
    PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    PROJECT_DIR=""
fi
REPO_RAW_BASE="https://raw.githubusercontent.com/Bhanu2ko3/cbproxy/main"
USER_BIN_DIR="$HOME/.local/bin"
USER_CONFIG_DIR="$HOME/.config/cbproxy"
USER_SERVICE_DIR="$HOME/.config/systemd/user"

echo -e "\033[0;36m\033[1m"
cat << 'EOF'
 ██████╗ ██████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗
██╔════╝ ██╔══██╗██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝
██║      ██████╔╝██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝ 
██║      ██╔══██╗██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝  
╚██████╗ ██████╔╝██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║   
 ╚═════╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   
EOF
echo -e "\033[0m\033[0;36m:: CodebroAI CBPROXY // SYSTEM INSTALLER & TUNNEL SETUP ::\033[0m"
echo -e "\033[0;36m:: Philosophy: Zero Bloat • Zero Root Dependency • Strict Tunnel Routing ::\033[0m"
echo "------------------------------------------------------------------"

if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "[ERROR] cbproxy is specifically engineered for Linux environments."
    exit 1
fi

echo "[INFO] Detecting core engine binary..."
ENGINE_BIN=""
CANDIDATES=(
    "/snap/v2raya/current/usr/local/bin/v2ray"
    "/usr/local/bin/xray"
    "/usr/bin/xray"
    "/usr/local/bin/v2ray"
    "/usr/bin/v2ray"
    "$(which xray 2>/dev/null || true)"
    "$(which v2ray 2>/dev/null || true)"
)

for path in "${CANDIDATES[@]}"; do
    if [[ -n "$path" && -x "$path" ]]; then
        ENGINE_BIN="$path"
        break
    fi
done

if [[ -z "$ENGINE_BIN" ]]; then
    echo "[WARN] Core engine (xray/v2ray) not detected."
    echo -n "Install official Xray-core now? (Requires sudo) [Y/n]: "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY]|"") ]]; then
        bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)"
        ENGINE_BIN="/usr/local/bin/xray"
    else
        echo "[ERROR] Xray or V2Ray engine is required to operate."
        exit 1
    fi
fi

echo "[OK] Engine found: $ENGINE_BIN"

# Directory Preparation (XDG Compliance)
mkdir -p "$USER_BIN_DIR"
mkdir -p "$USER_CONFIG_DIR"
mkdir -p "$USER_SERVICE_DIR"

# Install binary to ~/.local/bin
if [[ -n "$PROJECT_DIR" && -f "$PROJECT_DIR/bin/cbproxy" ]]; then
    cp "$PROJECT_DIR/bin/cbproxy" "$USER_BIN_DIR/cbproxy"
    chmod +x "$PROJECT_DIR/bin/cbproxy"
else
    echo "[INFO] Downloading cbproxy binary from GitHub..."
    curl -fsSL "$REPO_RAW_BASE/bin/cbproxy" -o "$USER_BIN_DIR/cbproxy"
fi
chmod +x "$USER_BIN_DIR/cbproxy"
echo "[OK] Binary installed to $USER_BIN_DIR/cbproxy"

# Setup initial configuration in ~/.config/cbproxy if not already present
if [ ! -f "$USER_CONFIG_DIR/config.json" ]; then
    if [[ -n "$PROJECT_DIR" && -f "$PROJECT_DIR/config/config.json" ]]; then
        cp "$PROJECT_DIR/config/config.json" "$USER_CONFIG_DIR/config.json"
    elif [[ -n "$PROJECT_DIR" && -f "$PROJECT_DIR/config/config.example.json" ]]; then
        cp "$PROJECT_DIR/config/config.example.json" "$USER_CONFIG_DIR/config.json"
    else
        echo "[INFO] Downloading default config template from GitHub..."
        curl -fsSL "$REPO_RAW_BASE/config/config.example.json" -o "$USER_CONFIG_DIR/config.json"
    fi
fi
if [[ -n "$PROJECT_DIR" && -f "$PROJECT_DIR/config/vless.txt" ]] && [ ! -f "$USER_CONFIG_DIR/vless.txt" ]; then
    cp "$PROJECT_DIR/config/vless.txt" "$USER_CONFIG_DIR/vless.txt"
fi

# Clean legacy service if active
if systemctl --user is-active --quiet meetlite-vpn 2>/dev/null; then
    systemctl --user stop meetlite-vpn 2>/dev/null || true
    systemctl --user disable meetlite-vpn 2>/dev/null || true
    rm -f "$USER_SERVICE_DIR/meetlite-vpn.service"
fi

# Generate universal systemd service unit
cat > "$USER_SERVICE_DIR/cbproxy.service" << EOF
[Unit]
Description=CodebroAI cbproxy Daemon
After=network.target

[Service]
Type=simple
ExecStart=$ENGINE_BIN run -c %h/.config/cbproxy/config.json
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
echo "[OK] Registered systemd user service (%h/.config/systemd/user/cbproxy.service)"

# Configure shell environment in ~/.bashrc
BASHRC="$HOME/.bashrc"
if grep -q "MeetLite VPN Proxy Auto-Environment" "$BASHRC" 2>/dev/null; then
    sed -i '/# MeetLite VPN Proxy Auto-Environment/,/alias vpn=/d' "$BASHRC" 2>/dev/null || true
fi

# Clean any old alias vpn
sed -i '/alias vpn=/d' "$BASHRC" 2>/dev/null || true

if ! grep -q "CodebroAI cbproxy Auto-Environment" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" << EOF

# CodebroAI cbproxy Auto-Environment
if [ -f "\$HOME/.config/cbproxy/.proxy_active" ]; then
    export http_proxy="http://127.0.0.1:10809"
    export https_proxy="http://127.0.0.1:10809"
    export all_proxy="socks5://127.0.0.1:10808"
fi

alias cbproxy='source \$HOME/.local/bin/cbproxy'
EOF
    echo "[OK] Added cbproxy alias and environment hooks to ~/.bashrc"
fi

echo "-----------------------------------------"
echo "[SUCCESS] Installation finished."
echo "Commands: cbproxy on | cbproxy off | cbproxy status | cbproxy --help"
