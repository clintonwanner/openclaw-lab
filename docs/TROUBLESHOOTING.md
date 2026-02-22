# Troubleshooting Guide

## Persistence Issues
**Symptom:** "Pairing Required" appears after every restart.
**Cause:** The container was recreated without restoring the configuration backup.
**Fix:** 
1.  Ensure the `<PROJECT_ROOT>/sandbox_data/openclaw_backup` directory contains a valid `openclaw.json`.
2.  The `entrypoint.sh` script is designed to automatically copy this file to `/root/.openclaw/` on startup. Check container logs (`docker logs openclaw_vm`) to see if the restore step failed.

**Symptom:** Files saved in `/app/workspace` disappear.
**Cause:** Docker volume mount failure.
**Fix:** The current setup uses a **Host Bind Mount** to `<PROJECT_ROOT>/sandbox_data`. Ensure this directory exists and is writable by the user.

## Gateway Connectivity Issues
**Symptom:** Gateway is "Unreachable" or "Unauthorized" in the Control UI.
**Causes:**
1.  **Token Mismatch:** The token in `.env` does not match the token in `openclaw.json`.
2.  **Port Conflict:** Port 18789 is being used by another process.
3.  **Schema Error:** An invalid key in `openclaw.json` is preventing the gateway from booting.

**Fixes:**
1.  **Sync Tokens:** Compare `OPENCLAW_GATEWAY_TOKEN` in `.env` with `gateway.auth.token` in `sandbox_data/openclaw_config/openclaw.json`. They must be identical.
2.  **Repair Config:** Run `oc fix` to automatically remove unrecognized keys (e.g., legacy `url` keys in auth profiles).
3.  **Check Logs:** Run `oc logs` to see if the gateway is receiving a `SIGTERM` or failing to bind to the port.

## Configuration Schema Errors
**Symptoms:** `openclaw doctor` reports "Unrecognized key" or "Problem: - auth.profiles...".
**Fix:**
Run the repair command:
```bash
oc fix
```
This is essential when upgrading OpenClaw or manually editing `openclaw.json`, as the agent is sensitive to unrecognized properties.

## Critical: Agent Crash on Startup
**Symptoms:** `openclaw_vm` container exits immediately or loops.
**Cause:** Missing API keys or invalid configuration in `openclaw.json`.

### Debugging Steps

1.  **Check Sync Status:**
    Verify if `.env` and `openclaw.json` are in lockstep:
    ```bash
    oc config status
    ```

2.  **Verify Model Accessibility:**
    If the gateway crashes, it might be due to an invalid model ID. Switch back to a known-good model:
    ```bash
    oc config model
    ```

3.  **Check Logs:**
    ```bash
    oc logs
    ```

3.  **Manual Start Attempt:**
    Inside the container, try running the gateway manually to see the error:
    ```bash
    openclaw gateway
    ```

4.  **Validate Config:**
    Run the doctor command to identify configuration issues:
    ```bash
    openclaw doctor
    ```

## Service Management
**Symptom:** `oc restart` or `systemctl restart openclaw-stack` returns quickly but the containers do not actually restart (uptime remains high).
**Cause:** The systemd service was missing an `ExecStop` directive, so it didn't tear down the stack before trying to start it again. Docker Compose's idempotency meant no changes were applied.
**Fix:** 
1.  Ensure `/etc/systemd/system/openclaw-stack.service` includes `ExecStop=/usr/bin/docker compose down`.
2.  Reload systemd: `systemctl daemon-reload`.
3.  The `oc` CLI wrapper now handles this correctly.

---

## Network Issues
**Error:** Agent cannot reach the internet.
**Check:**
1.  Verify DNS settings in `docker-compose.yml` (AdGuard: `94.140.14.14`).
2.  Test connectivity from inside the container:
    ```bash
    docker exec openclaw_vm curl -I https://openrouter.ai
    ```

## WSS Connection / Certificate Issues
**Symptom:** Browser shows "Your connection is not private" or Control UI fails to connect.
**Cause:** The gateway uses a self-signed certificate for WSS.
**Fix:**
1. Visit the gateway URL directly in your browser (e.g., `https://172.30.0.4:18789`).
2. Click **Advanced** → **Proceed** to trust the certificate for your session.
3. If using a client that supports pinning, use the SHA-256 fingerprint from `GEMINI.md`.

**Symptom:** Disconnected (1008): pairing required (even after approval).
**Cause:** Stale session tokens or cached security state in the browser.
**Fix:**
1. Perform a **Hard Refresh** (`Ctrl + F5`).
2. If the loop persists, open Browser DevTools (`F12`) → **Application** → **Clear site data**, then reload.
3. Ensure you are using the URL with the `#token=` fragment appended.

**Symptom:** Internal agent reports "Gateway Status: ❌ Connect Failed" or "self-signed certificate".
**Cause:** The CLI tools inside the container do not trust the self-signed certificate by default, or the host firewall is dropping bridge traffic.
**Fix:** 
1. Ensure `OPENCLAW_GATEWAY_URL=wss://127.0.0.1:18789` is set in `.env` to bypass the bridge firewall.
2. Ensure `NODE_TLS_REJECT_UNAUTHORIZED=0` is set in the container environment. 
This allows the agent to communicate securely with the local gateway without requiring a CA-signed certificate.

**Symptom:** Sub-agent spawning fails with "gateway closed (1008): pairing required".
**Cause:** Scope mismatch. The agent identity lacks `operator.write` or other necessary scopes, and the gateway rejects the "unauthorized scope upgrade" connection.
**Fix:**
1. Stop the stack (`oc down`).
2. Manually add missing scopes (`operator.admin`, `operator.approvals`, `operator.pairing`, `operator.read`, `operator.talk`, `operator.write`) to `devices/paired.json` and `identity/device-auth.json`.
3. Clear `devices/pending.json`.
4. Restart the stack (`oc up`).

## Time Drift / NTP Issues
**Symptom:** Logs show incorrect timestamps, or time-sensitive tokens fail.
**Cause:** Host clock is not synchronized with an NTP server.
**Fix:**
1. Check sync status: `chronyc tracking`
2. Force a sync: `sudo chronyc -a makestep`
3. Verify against external time: `curl -sI google.com | grep -i '^Date:'`

## Warden Sentry Access Errors
**Symptom:** Warden logs show "ERROR: Can't access file ... .tmp".
**Cause:** Race condition where transient `.tmp` files are deleted by OpenClaw before Warden can scan them.
**Fix:**
1. The Warden script has been updated to exclude `.tmp` files.
2. If other file types cause issues, ensure the `warden` container has correct read permissions for the mounted volume.
3. Check for UID/GID mismatches between host and containers.
