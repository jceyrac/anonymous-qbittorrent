#!/bin/bash
# Auto-configures qBittorrent's port using forwarded port from VPN container
set -euo pipefail

cd /path/to/docker/project  # Generic path

# Get current forwarded port from VPN container
NEW_PORT=$(docker exec vpn_container cat /path/to/forwarded_port_file)
CONFIG_FILE="./qbittorrent/config/qBittorrent.conf"  # Generic config path

# Update config file with new port and credentials
sed -i.bak \
  -e "s/\(Connection\\\PortRangeMin=\).*/\1$NEW_PORT/" \
  -e "/Connection\\\PortRangeMin=/a Connection\\\PortRangeMax=$NEW_PORT" \
  -e "s/\(Session\\\Port=\).*/\1$NEW_PORT/" \
  -e "s/\(WebUI\\\Username=\).*/\1admin/" \
  -e "s|\(WebUI\\\Password_PBKDF2=\).*|\1@ByteArray(GENERIC_HASH_VALUE)|" \
  "$CONFIG_FILE"

# Verification output
echo "qBittorrent successfully configured with port: $NEW_PORT"
docker exec qbittorrent_container grep -A1 "PortRangeMin" /config/qBittorrent.conf
