# 🚀 Complete Blueprint: Building Your Own Private VLESS SNI-Bypass Server

A comprehensive, step-by-step engineering guide to deploying, configuring, and maintaining your own high-speed, private, zero-rated (Zoom SNI) VLESS VPN server on cloud infrastructure.

---

## 📑 Table of Contents
1. [Architecture Overview](#1-architecture-overview)
2. [Prerequisites & Cost Estimation](#2-prerequisites--cost-estimation)
3. [Step 1: Provisioning the Cloud VPS](#step-1-provisioning-the-cloud-vps)
4. [Step 2: Server Security & Hardening](#step-2-server-security--hardening)
5. [Step 3: Installing 3X-UI (Xray Management Panel)](#step-3-installing-3x-ui-xray-management-panel)
6. [Step 4: Configuring the VLESS Inbound with SNI Spoofing](#step-4-configuring-the-vless-inbound-with-sni-spoofing)
7. [Step 5: Testing & Connecting to Your cbproxy Client](#step-5-testing--connecting-to-your-cbproxy-client)
8. [Step 6: Phone Setup (Android & iOS)](#step-6-phone-setup-android--ios)
9. [Step 7: Anti-Ban & Long-Term Maintenance Strategy](#step-7-anti-ban--long-term-maintenance-strategy)

---

## 1. Architecture Overview

```
+-------------------------------------------------------------+
|                     Client Device (Laptop)                  |
|  [Chrome / Antigravity]                                     |
|             |                                               |
|             v (HTTP Proxy: 127.0.0.1:10809)                 |
|       Local V2Ray Core                                      |
|  (Packs data into VLESS, sets SNI: zoom.us, TLS: Chrome fp) |
+-------------------------------------------------------------+
                              |
                              v (Encrypted TLS over Port 443)
+-------------------------------------------------------------+
|              ISP Gateway (Dialog / SLT / Mobitel)           |
|  Deep Packet Inspection (DPI) sees:                         |
|  - Destination Port: 443                                    |
|  - TLS SNI Header  : zoom.us                                |
|  - Verdict         : Zoom Call -> Billed to Zoom Package!   |
+-------------------------------------------------------------+
                              |
                              v (Forwarded directly)
+-------------------------------------------------------------+
|                Your Cloud VPS (e.g., Hetzner / Contabo)     |
|  3X-UI / Xray-Core Daemon (Port 443)                        |
|  - Validates UUID (ef05... or your unique key)              |
|  - Strips outer TLS wrapper                                 |
|  - Forwards requests to real destination (Google, YT, etc.) |
+-------------------------------------------------------------+
                              |
                              v (Unrestricted Gigabit Internet)
+-------------------------------------------------------------+
|                     Target Web Endpoints                    |
|   (Google DeepMind, YouTube, GitHub, OpenAI, etc.)          |
+-------------------------------------------------------------+
```

---

## 2. Prerequisites & Cost Estimation

| Component | Recommended Provider | Specs | Estimated Cost |
| :--- | :--- | :--- | :--- |
| **Cloud VPS** | [Hetzner Cloud](https://www.hetzner.com/cloud) *(Best value)* or [DigitalOcean](https://digitalocean.com) | 1 vCPU, 1 GB RAM, 20 GB SSD, 20 TB Traffic | ~€3.50 – $4.00 / mo (~LKR 1,200) |
| **Location** | Germany (Falkenstein) or Singapore | Singapore gives ~40ms ping; Germany gives ~130ms ping | Included |
| **Operating System** | Ubuntu 22.04 LTS or 24.04 LTS | 64-bit x86 | Free |
| **Domain (Optional)** | Namecheap / Cloudflare | Any `.xyz`, `.top` or free subdomain | ~$1 – $3 / year (or Free) |

> [!TIP]
> **Free Tier Option:** You can also deploy this on **Oracle Cloud Always Free Tier** (VM.Standard.A1.Flex or E2.1.Micro) for **$0/month forever**. However, Hetzner offers significantly better network stability and IP reputation.

---

## 3. Step 1: Provisioning the Cloud VPS

1. Sign up on your chosen cloud provider (e.g., **Hetzner Cloud** or **DigitalOcean**).
2. Create a new server instance:
   - **Image:** Ubuntu 22.04 LTS or 24.04 LTS
   - **Type:** Shared CPU (1 vCPU, 1 GB RAM or 2 GB RAM)
   - **Location:** 
     - **Singapore:** Lowest latency (ideal for gaming & interactive coding).
     - **Germany / Finland:** Highest bandwidth allowance (Hetzner gives 20 TB/month).
   - **Authentication:** SSH Key (Recommended) or Root Password.
3. Once booted, copy your server's **Public IPv4 Address** (e.g. `123.45.67.89`).

---

## 4. Step 2: Server Security & Hardening

Log in to your server via terminal:
```bash
ssh root@YOUR_SERVER_IP
```

Run basic system updates and enable a firewall:
```bash
# 1. Update package lists
apt update && apt upgrade -y

# 2. Install basic utility tools
apt install -y curl wget git ufw fail2ban

# 3. Configure Firewall (Allow SSH, HTTP, HTTPS, and 3X-UI panel)
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp      # SSH
ufw allow 80/tcp      # HTTP
ufw allow 443/tcp     # HTTPS / VLESS Tunnel
ufw allow 2053/tcp    # 3X-UI Admin Dashboard
ufw --force enable
```

---

## 5. Step 3: Installing 3X-UI (Xray Management Panel)

[3X-UI](https://github.com/MHSanaei/3x-ui) is the modern, open-source web interface that manages Xray-core seamlessly without manual JSON editing.

Run the official one-step installer:
```bash
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

During installation, the script will prompt you:
1. **Set Username:** Choose an admin username (e.g., `admin`).
2. **Set Password:** Choose a strong password.
3. **Set Port:** Press `Enter` for default `2053` (or choose a custom port).

Once installed, check status:
```bash
x-ui status
```

Now open your web browser on your laptop and visit:
👉 `http://YOUR_SERVER_IP:2053`

Log in using the credentials you just created.

---

## 6. Step 4: Configuring the VLESS Inbound with SNI Spoofing

Once inside the 3X-UI dashboard:

1. Click on **Inbounds** (වම් පැත්තේ Navigation menu එකේ) ➡️ Click **Add Inbound** (`+` button).
2. Fill in the configuration details as follows:

| Field | Value | Explanation |
| :--- | :--- | :--- |
| **Remark** | `Codebro-Private` | Any nickname for your tunnel |
| **Protocol** | `vless` | Lightweight, high-performance protocol |
| **Listening IP** | `0.0.0.0` | Listens on all interfaces |
| **Port** | `443` | Crucial: Must be 443 (standard HTTPS port) |
| **Client ID (UUID)** | Auto-generated | Keep this unique UUID |
| **Transmission (Network)** | `tcp` | Fast, standard transport |
| **Security** | `tls` | Enables TLS transport security |
| **SNI** | `zoom.us` | **The Bypass Secret:** Spoofs the TLS handshake header |
| **uTLS (Fingerprint)** | `chrome` | Masks traffic as genuine Google Chrome browser |
| **ALPN** | `h2,http/1.1` | HTTP/2 and HTTP/1.1 support |

3. Under **Certificates**:
   - If using a domain: Select your domain's Let's Encrypt certificate.
   - If using pure IP / Reality: Enable **Reality** mode, target `zoom.us:443`, which borrows the real TLS certificate of Zoom without needing your own domain!

4. Click **Create / Save**.

5. On the inbound card, click the **QR / Link Icon** (Show Link) and click **Copy**.
   - Your link will look like:
     ```text
     vless://<UUID>@YOUR_SERVER_IP:443?alpn=h2%2Chttp%2F1.1&encryption=none&fp=chrome&security=tls&sni=zoom.us&type=tcp#Codebro-Private
     ```

---

## 7. Step 5: Connecting to Your cbproxy Client

On your local machine:

Simply run the cbproxy auto-importer:
```bash
cbproxy import "YOUR_COPIED_VLESS_LINK"
```

Then start the proxy:
```bash
cbproxy on
```

Verify your connection and external IP:
```bash
vpn status
```

You should see:
```text
🔍 Testing Connection Status:
   [Service] : 🟢 Active (Running)
   [VPN IP]  : 🌐 <YOUR_SERVER_IP> (Traffic routed through VLESS server)
```

---

## 8. Step 6: Phone Setup (Android & iOS)

### Android:
1. Install **v2rayNG** or **NekoBox** from Google Play Store or GitHub.
2. Open the app ➡️ Tap `+` (Top right) ➡️ Select **Import config from Clipboard**.
3. Tap the connected server and tap the **V** button (Connect) at the bottom.
4. Your entire Android phone now routes through your private Zoom tunnel!

### iOS (iPhone):
1. Install **V2Box** or **Streisand** from Apple App Store.
2. Tap **Configs** ➡️ **+** ➡️ **Import from Clipboard**.
3. Toggle the connect switch.

---

## 9. Step 7: Anti-Ban & Long-Term Maintenance Strategy

To make sure your private server lasts for months/years without being blocked by Dialog / SLT:

### 1. The Single-User Advantage
Because you are the sole user of this server, your daily bandwidth pattern (3–10 GB) looks virtually indistinguishable from a regular human working from home via Zoom. Unlike public sellers who host 100+ users on one IP, your IP will rarely trigger ISP anomaly detection.

### 2. If an IP Ever Gets Flagged:
If the ISP blocks your VPS IP in the future, don't delete your server:
1. In **Hetzner / DigitalOcean**, simply unassign the IPv4 address and attach a new floating IP (~€0.50).
2. Or use **Cloudflare CDN** as a reverse proxy shield in front of your server (`WebSocket + CDN` mode), which makes the server's real IP completely invisible to the ISP.

### 3. Server Maintenance Commands:
```bash
# Check resource usage on your VPS
htop

# Check 3X-UI service status
x-ui status

# Restart 3X-UI if needed
x-ui restart
```

---

## 🏆 Summary Checklist

- [x] VPS provisioned on Hetzner / DigitalOcean
- [x] Firewall configured with ports `22`, `443`, and `2053` open
- [x] 3X-UI installed via one-line installer
- [x] VLESS inbound created with `port: 443`, `sni: zoom.us`, `fp: chrome`
- [x] VLESS link imported to local client via `cbproxy import`
- [x] Verified routing via `cbproxy status`

*Maintained by CodebroAI Software Studio — Technical Documentation.*
