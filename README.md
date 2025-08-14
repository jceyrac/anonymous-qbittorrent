# Anonymous qBittorrent with ProtonVPN & Docker  
*A secure torrenting setup that isolates traffic through a WireGuard VPN with persistent port forwarding*

![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=flat&logo=docker&logoColor=white)  
![ProtonVPN](https://img.shields.io/badge/ProtonVPN-8B89CC?style=flat&logo=protonvpn&logoColor=white)  
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat&logo=ubuntu&logoColor=white)

---

## 🚀 Project Goals  
1. **Isolate qBittorrent traffic** through VPN to dissociate it from the server's public IP  
2. **Enable port forwarding** for optimal seeding/leeching  
3. **Maintain other services** (e.g., Nextcloud, Jellyfin) on the regular network  
4. **Automate port updates** when VPN-forwarded ports change  

---

## ❌ Failed Approaches  
| Attempt                | Issue                                  |  
|------------------------|----------------------------------------|  
| **PIA VPN**            | Unstable port forwarding               |  
| **Basic ProtonVPN**    | No port forwarding support             |  
| **Network Namespaces** | Overly complex configuration           |  
| **Mullvad VPN**        | Port forwarding discontinued           |  

**✅ Final Solution**:  
ProtonVPN **Unlimited Plan** + Docker (Gluetun + qBittorrent)  

---

## ⚙️ System Overview  
- **Host OS**: Ubuntu Server 22.04 LTS  
- **Network**: Dual-stack (IPv4/IPv6)  
- **qBittorrent UID**: `[REDACTED]`  
- **Web UI Port**: `[CUSTOM_PORT]`  

---

## 📦 Repository Structure  
```
.
├── docker-compose.yml          # Main deployment config  
├── gluetun/                    # VPN persistent data  
├── qbittorrent/                # qBittorrent configs  
├── update-port.sh              # Port sync script  
└── README.md                   # This guide  
```

---

## 🛠️ Setup Guide  

### 1. Prerequisites  
- [ProtonVPN Unlimited](https://protonvpn.com) subscription  
- Docker & Docker-Compose:  
  ```bash  
  sudo apt update && sudo apt install docker.io docker-compose  
  ```  

### 2. Configure `docker-compose.yml`  
```yaml  
version: "3.8"  
services:  
  gluetun:  
    image: qmcgaw/gluetun  
    environment:  
      - VPN_PORT_FORWARDING=on  
      - VPN_SERVICE_PROVIDER=protonvpn  
      - WIREGUARD_PRIVATE_KEY=your_private_key  

  qbittorrent:  
    image: linuxserver/qbittorrent  
    network_mode: "service:gluetun"  
    volumes:  
      - ./qbittorrent:/config  
      - /mnt/share:/downloads  # External storage  
```  

### 3. Port Forwarding Script  
`update-port.sh`:  
```bash  
#!/bin/bash  
NEW_PORT=$(docker exec gluetun cat /gluetun/forwarded_port)  
sed -i "s/\(Session\\\Port=\).*/\1$NEW_PORT/" ./qbittorrent/qBittorrent.conf  
```  

### 4. Storage Integration  
```bash  
sudo mkdir -p /mnt/share  
sudo mount -t cifs //server/share /mnt/share -o credentials=/etc/samba/credentials  
```  

---

## 🔍 Key Features  
- **Auto port sync**: Script updates qBittorrent with VPN's forwarded port  
- **External storage**: Save torrents to NAS/Samba shares  
- **Traffic isolation**: Only qBittorrent uses VPN  

---

## 📜 Lessons Learned  
1. **ProtonVPN Unlimited** is required for reliable port forwarding  
2. **Gluetun** simplifies VPN routing vs. manual iptables  
3. **Permission parity** between Docker and storage is critical  

---

## 🔗 References  
- [Gluetun Docs](https://github.com/qdm12/gluetun)  
- [ProtonVPN Port Forwarding](https://protonvpn.com/support/port-forwarding/)  

---

**🌟 Pro Tip**:  
```bash  
0 * * * * /path/to/update-port.sh >> /var/log/port_update.log 2>&1  
```  
*Cron job ensures ports stay synced after VPN reconnects*  

--- 

*All identifiable details (IPs, hostnames, UIDs) have been redacted for public sharing.*  

