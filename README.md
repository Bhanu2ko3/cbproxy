<div align="center">

# 🚀 cbproxy (CodebroAI Proxy)
### *Native Linux CLI VPN Controller & Multi-Protocol Auto-Proxy Engine*

*An ultra-lightweight, zero-RAM, developer-first command-line VPN and tunneling manager for Linux. Engineered for multi-protocol Xray-core transport (VLESS, VMess, Trojan) with automated 3-layer system routing.*

---

[![Release](https://img.shields.io/badge/Release-v1.0.0--Production-00D4B2?style=flat-square)](#)
[![Platform](https://img.shields.io/badge/Platform-Linux%20(systemd%20%7C%20GNOME)-FF6B6B?style=flat-square)](#)
[![Core Engine](https://img.shields.io/badge/Engine-Xray%20%7C%20V2Ray-4D96FF?style=flat-square)](#)
[![Protocols](https://img.shields.io/badge/Protocols-VLESS%20%7C%20VMess%20%7C%20Trojan-6BCB77?style=flat-square)](#)
[![Security](https://img.shields.io/badge/Security-Rootless%20(No%20Sudo)-9D4EDD?style=flat-square)](#)
[![IDEs Supported](https://img.shields.io/badge/IDEs-Antigravity%20%7C%20VS%20Code%20%7C%20VSCodium-FFB703?style=flat-square)](#)
[![License](https://img.shields.io/badge/License-MIT-343A40?style=flat-square)](LICENSE)

</div>

---

## ⚡ Architectural Highlights

- **Zero Extra RAM Overhead:** Built with high-efficiency bash and Python. Operates without resource-heavy Electron/Qt desktop apps eating 300MB+ memory.
- **Rootless & Non-Intrusive:** Executes fully in user-space via `systemctl --user`. Never requests or requires `sudo` privileges for daily start, stop, or status checks.
- **Automated 3-Layer System Routing:**
  1. **Desktop & Browsers:** Synchronizes with GNOME Desktop Proxy (`org.gnome.system.proxy`) for Chrome, Firefox, Brave, and native desktop clients.
  2. **Shell Environment:** Injects `http_proxy`, `https_proxy`, and `all_proxy` dynamically into terminal sessions for CLI utilities (`curl`, `git`, `npm`, `pip`, `docker`).
  3. **Developer IDEs:** Performs hot-reload configuration for **Antigravity IDE**, **Visual Studio Code**, and **VSCodium** user settings without restarting background AI daemons.
- **Multi-Protocol Engine:** Auto-parses and builds valid Xray/V2Ray client configurations from raw URLs:
  - `vless://` (Lightweight stateless tunneling)
  - `vmess://` (Base64 JSON encoded standard)
  - `trojan://` (Stealth HTTPS disguise)
- **Localhost Loopback Isolation:** All inbound listeners bind exclusively to `127.0.0.1`. Completely inaccessible from external networks or local Wi-Fi.

---

## 🚀 Quick Start & Installation

### Option 1: Local Setup
```bash
# Clone the repository
git clone https://github.com/Bhanu2ko3/cbproxy.git
cd cbproxy

# Run the installer
./setup.sh
```

### Option 2: One-Line Remote Installer
```bash
curl -fsSL https://raw.githubusercontent.com/Bhanu2ko3/cbproxy/main/setup.sh | bash
```

The automated installer will:
1. Detect or offer to install the core Xray engine.
2. Place the executable in `~/.local/bin/cbproxy`.
3. Register the systemd user service via XDG standards (`%h/.config/cbproxy/config.json`).
4. Append the `cbproxy` command alias into your `~/.bashrc`.

---

## 💻 Command Reference & Usage

Control your entire proxy tunnel from any terminal session:

```text
:: CodebroAI cbproxy // Native Linux CLI Proxy Controller ::

USAGE:
    cbproxy [COMMAND] [OPTIONS]

COMMANDS:
    on, start          Start proxy daemon & auto-configure system/terminal/IDEs
    off, stop          Stop proxy daemon & cleanly restore normal direct connection
    status             Display service state and verified external IP address
    import <URL>       Import and build config from a vless://, vmess://, or trojan:// URL
    restart            Restart active proxy service
    help, -h, --help   Display this command reference
```

### Examples

```bash
# 1. Import a new configuration link
cbproxy import "vless://00000000-0000-0000-0000-000000000000@example.com:443?security=tls&sni=example.com#node"

# 2. Connect and route all traffic
cbproxy on

# 3. Check live connection health and verified public IP
cbproxy status

# 4. Disconnect and revert system to direct connection
cbproxy off
```

---

## 📁 Repository Structure

```text
cbproxy/
├── bin/
│   └── cbproxy                  # Core CLI executable controller
├── config/
│   ├── cbproxy.service          # User systemd service unit template (%h specifier)
│   └── config.example.json      # Xray/V2Ray client configuration template
├── docs/
│   └── BUILD-YOUR-OWN-VPN.md    # Guide to deploying your own cloud server
├── .gitignore                   # Git exclusion rules
├── LICENSE                      # MIT Open-Source License
├── README.md                    # Project documentation
└── setup.sh                     # Automated Linux system installer
```

---

## 🌐 How It Works (Traffic Flow)

```text
[ Chrome / Antigravity / Terminal / CLI ]
                   │
                   ▼ (Local Inbound: HTTP 10809 / SOCKS5 10808)
         [ Local Core Engine ]
                   │
                   ▼ (TLS Tunnel with Custom SNI e.g. example.com)
            [ Network Gateway ]  ──> [ Inspected as Standard HTTPS (Port 443) ]
                   │
                   ▼ (Encrypted Transit over Port 443)
       [ Remote Proxy Server ] (Xray-core / 3X-UI Cloud Gateway)
                   │
                   ▼ (Direct Gigabit Web Access)
         [ Target Internet Endpoints ] (Google DeepMind, GitHub, etc.)
```

---

## 📄 License
Distributed under the **MIT License**. See `LICENSE` for details.  
Maintained by **CodebroAI Software Studio** — [https://codebroai.com](https://codebroai.com).
