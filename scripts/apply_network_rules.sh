#!/bin/bash
# OpenClaw Network Security - Idempotent Bridge Detection
# Blocks LAN access for the isolated Docker bridge.

# 1. Dynamically find the bridge ID for our isolated network
BRIDGE_ID=$(docker network inspect openclaw-lab_isolated_vlan -f '{{.Id}}' 2>/dev/null | cut -c1-12)
BRIDGE_NAME="br-$BRIDGE_ID"

if [ -z "$BRIDGE_ID" ]; then
    echo "[!] Error: Isolated network 'openclaw-lab_isolated_vlan' not found."
    exit 1
fi

echo "[*] Detected Bridge: $BRIDGE_NAME"

# 2. Define the networks to block
NETWORKS=("192.168.0.0/16" "10.0.0.0/8" "172.16.0.0/12")

# 3. Apply rules idempotently (check if exists before adding)
for NET in "${NETWORKS[@]}"; do
    if iptables -C FORWARD -i "$BRIDGE_NAME" -d "$NET" -j DROP 2>/dev/null; then
        echo "[+] Rule already exists for $NET on $BRIDGE_NAME"
    else
        echo "[-] Adding block rule for $NET on $BRIDGE_NAME..."
        iptables -I FORWARD -i "$BRIDGE_NAME" -d "$NET" -j DROP
    fi
done

echo "[*] Network isolation rules verified."
