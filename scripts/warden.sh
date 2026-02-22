#!/bin/bash

# Configuration
WATCH_DIR="/scandir"
JAIL_DIR="/jail"                 # Local to Warden (Agent cannot access this)
LOG_FILE="$WATCH_DIR/warden_audit.log"
MAX_LOG_LINES=1000

# Setup Environments
mkdir -p "$JAIL_DIR"
touch "$LOG_FILE"

# Log Function with Rotation
log_alert() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [WARDEN] $1" | tee -a "$LOG_FILE"
    # Keep log file clean (tail last 1000 lines)
    if [ $(wc -l < "$LOG_FILE") -gt $MAX_LOG_LINES ]; then
        echo "$(tail -$MAX_LOG_LINES "$LOG_FILE")" > "$LOG_FILE"
    fi
}

log_alert "Initialization: Warden is watching $WATCH_DIR"
log_alert "Policy: Quarantine threats to $JAIL_DIR (No Kill)"

# Ensure ClamAV Daemon is running
if [ ! -d "/run/clamav" ]; then
    mkdir -p /run/clamav
    chown clamav:clamav /run/clamav
fi
clamd &

# Wait for ClamAV to load DB
while [ ! -S /run/clamav/clamd.sock ]; do
    echo "Waiting for ClamAV Daemon..."
    sleep 2
done
log_alert "ClamAV Daemon is active."

# --- THE WATCH LOOP ---
# One-liner to avoid shell escaping issues
inotifywait -m -r -e close_write -e moved_to --format '%w%f' --exclude '/(\.git/|warden_audit\.log|\.tmp$)' "$WATCH_DIR" | while read FILE
do
    if [ -f "$FILE" ]; then
        SCAN_OUTPUT=$(clamdscan --no-summary --fdpass "$FILE" 2>/dev/null)
        SCAN_EXIT=$?

        if [ $SCAN_EXIT -eq 1 ]; then
            VIRUS_NAME=$(echo "$SCAN_OUTPUT" | grep -o 'FOUND.*' | cut -d: -f 2)
            log_alert "!!! THREAT DETECTED: $FILE ($VIRUS_NAME) !!!"
            BASENAME=$(basename "$FILE")
            JAIL_PATH="$JAIL_DIR/${BASENAME}_$(date +%s).infected"
            mv "$FILE" "$JAIL_PATH"
            echo "---------------------------------------------------" > "$FILE.quarantined.txt"
            echo "SECURITY ALERT: The file '$BASENAME' was quarantined." >> "$FILE.quarantined.txt"
            echo "Reason: Identified as $VIRUS_NAME" >> "$FILE.quarantined.txt"
            echo "Action: File moved to Administrator Jail." >> "$FILE.quarantined.txt"
            echo "---------------------------------------------------" >> "$FILE.quarantined.txt"
            log_alert "Action Taken: Quarantined to $JAIL_PATH"
        elif [ $SCAN_EXIT -eq 0 ]; then
            :
        elif [ $SCAN_EXIT -eq 2 ] && [ ! -f "$FILE" ]; then
            # File likely renamed or deleted before scan could finish (common for .tmp files)
            :
        else
            log_alert "Error: Scan failed on $FILE (Exit: $SCAN_EXIT)"
        fi
    fi
done