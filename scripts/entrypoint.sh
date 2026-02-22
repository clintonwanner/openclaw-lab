#!/bin/bash
set -e

# Initialize D-Bus session bus
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
    export DBUS_SESSION_BUS_ADDRESS
fi

# Initialize gnome-keyring-daemon
export $(echo "" | gnome-keyring-daemon --components=secrets --unlock 2>/dev/null || true)

# Path to the persistent config
MOUNTED_CONFIG="/app/.openclaw"
PRISONER_HOME="/home/prisoner"
LOCAL_CONFIG="$PRISONER_HOME/.openclaw"

# Symlink persistent config to the place OpenClaw expects it
if [ ! -L "$LOCAL_CONFIG" ]; then
    rm -rf "$LOCAL_CONFIG"
    ln -s "$MOUNTED_CONFIG" "$LOCAL_CONFIG"
fi

# Path to the persistent backup
BACKUP_DIR="/app/workspace/openclaw_backup"
CONFIG_PATH="$MOUNTED_CONFIG/openclaw.json"

# Restore backup if it exists and config doesn't
if [ -d "$BACKUP_DIR" ] && [ ! -f "$CONFIG_PATH" ]; then
    echo "[Boot] Restoring OpenClaw config from backup..."
    mkdir -p "$MOUNTED_CONFIG"
    cp -r "$BACKUP_DIR/." "$MOUNTED_CONFIG/"
fi

# Check if we have a valid config to auto-start the gateway
if [ -f "$CONFIG_PATH" ]; then
    echo "[Boot] Found existing configuration at $CONFIG_PATH"

    # Step 1: Secure permissions (Satisfy internal security checks)
    echo "[Boot] Securing configuration permissions..."
    chmod 700 "$MOUNTED_CONFIG" || true
    chmod 600 "$CONFIG_PATH" || true

    # Step 2: Auto-heal configuration errors (Unrecognized keys, deprecations)
    echo "[Boot] Running 'openclaw doctor --non-interactive' for auto-healing..."
    # Run doctor quietly; if it fails, we still try to boot the gateway
    openclaw doctor --non-interactive --quiet > /dev/null 2>&1 || echo "[Boot] WARNING: 'doctor' could not resolve all issues."

    # Step 3: Clear stale session locks (Proactive fix)
    echo "[Boot] Clearing stale session locks..."
    find "$MOUNTED_CONFIG/agents" -name "*.lock" -type f -delete 2>/dev/null || true

    echo "[Boot] Starting OpenClaw Gateway..."
    
    # Start OpenClaw gateway
    exec openclaw gateway run \
        --allow-unconfigured \
        --bind "${OPENCLAW_BIND:-lan}" \
        --port "${OPENCLAW_PORT:-18789}" \
        --token "${OPENCLAW_GATEWAY_TOKEN}" \
        --verbose
else
    echo "[Boot] No configuration found. Container is ready for manual setup."
    echo "[Boot] Run 'openclaw onboard' via 'oc shell'."
    exec tail -f /dev/null
fi