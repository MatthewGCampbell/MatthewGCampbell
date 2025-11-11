#!/bin/bash
# Configure DNS client settings on all lab containers (except ns1/ns2)
# Usage: bash configure_dns_clients.sh <lastname>
# Example: bash configure_dns_clients.sh campbell

set -euo pipefail

# --- Check argument ---
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <lastname>"
  exit 1
fi

LASTNAME="$1"
DOMAIN="${LASTNAME}.itis3246.lab"

# Map container name -> IP
declare -A IPS=(
  [client0]="172.16.31.100"
  [client1]="172.16.31.101"
  [ldap]="172.16.31.14"
  [krb]="172.16.31.16"
  [irc]="172.16.31.17"
  # Uncomment when server0 exists:
  # [server0]="172.16.31.250"
)

for CT in "${!IPS[@]}"; do
  IP="${IPS[$CT]}"

  echo
  echo "=============================="
  echo "[+] Configuring ${CT} (${IP})"
  echo "=============================="

  # Skip if container doesn't exist
  if ! lxc info "$CT" &>/dev/null; then
    echo "[-] Container $CT not found, skipping."
    continue
  fi

  lxc exec "$CT" -- bash -c "
    set -e

    # 1) Replace resolv.conf to point to ns1/ns2
    rm -f /etc/resolv.conf
    cat > /etc/resolv.conf <<EOF
nameserver 172.16.31.11
nameserver 172.16.31.12
search ${DOMAIN}
EOF

    # 2) Set hostname
    echo \"${CT}.${DOMAIN}\" > /etc/hostname
    if command -v hostnamectl >/dev/null 2>&1; then
      hostnamectl set-hostname \"${CT}.${DOMAIN}\" || hostname \"${CT}.${DOMAIN}\"
    else
      hostname \"${CT}.${DOMAIN}\"
    fi

    # 3) Set /etc/hosts
    cat > /etc/hosts <<EOF
127.0.0.1   localhost
${IP}       ${CT}.${DOMAIN} ${CT}

::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

    # 4) Make sure dnsutils is installed (for dig)
    apt-get update -y >/dev/null 2>&1 || true
    apt-get install -y dnsutils >/dev/null 2>&1 || true
  "

done

echo
echo "[✓] DNS client configuration done on all listed containers."
echo "    Try: lxc exec client0 -- dig client1.${DOMAIN}"
