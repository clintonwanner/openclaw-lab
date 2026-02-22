# Maintenance & Operations

## System Management (Docker Compose)
The stack is managed by **Docker Compose** to ensure orchestration and persistence.

**Start the Stack:**
```bash
cd ~/openclaw-lab
docker compose up -d
```

**Stop the Stack:**
```bash
cd ~/openclaw-lab
docker compose down
```

**View Status:**
```bash
docker compose ps
```

**View Logs:**
```bash
docker compose logs -f
```

## Configuration Management (oc config)
The `oc` CLI provides a surgical interface for managing models, providers, and API keys.

**Commands:**
*   `oc config model`: Interactive menu to switch primary LLM models. Note: Switching the primary model does not affect the `fallbacks` chain.
*   `oc config provider`: Switch active providers or add a new one (`oc config provider add`).
*   `oc config key`: Add or update API keys in `.env` and `docker-compose.yml`.
*   `oc config status`: Verify synchronization between config files.

### Model Tiers (Primary & Fallback)
The sandbox uses a multi-tier model configuration in `openclaw.json`:
1.  **Primary**: The default model used for all agent operations (e.g., `nvidia/moonshotai/kimi-k2.5`).
2.  **Fallbacks**: A sequential list of models attempted if the primary fails:
    - `gemini/gemini-2.5-flash` (Reliable 1st Tier)
    - `openrouter/auto` (Dynamic 2nd Tier)
    - `ollama/deepseek-r1:14b` (Local 3rd Tier Fail-safe)

**Important:** All agents (`main`, `coder`, `researcher`, `strategist`, `reviewer`) must now follow the standard schema where `model` is an object with `primary` and `fallbacks`. Single-string model configurations are deprecated and offer no redundancy.

To update the fallback chain, manually edit `agents.defaults.model.fallbacks` in `openclaw.json` and run `oc fix`.

### Adding a New Provider
To add a new AI service (e.g., Groq, Anthropic):
1.  Run `oc config provider add`.
2.  Follow the prompts for ID, URL, and API Key.
3.  The tool automatically:
    - Adds the key to `.env`.
    - Passes the key to the container via `docker-compose.yml`.
    - Scaffolds the JSON block in `openclaw.json`.
    - Validates the gateway can still boot.

### Search Engine API Keys
Tools like `web_search` often require external search engine keys.
- **Brave Search**: Managed via `BRAVE_SEARCH_API_KEY` in `.env`.
- **Tavily**: Managed via `TAVILY_API_KEY` in `.env`.
These keys are passed to the container via `docker-compose.yml` and are automatically picked up by the agent's web tools.

### Security & Safety
Every `oc config` change is atomic. The tool creates "Trinity Backups" (`.env.bak`, `openclaw.json.bak`, `docker-compose.yml.bak`) before applying changes. If the gateway fails its post-update health check, the system **automatically rolls back** to the previous working state.

## Gateway Authentication
The Gateway uses a token-based authentication system. This token MUST be synchronized between two places:
1.  **`.env`**: `OPENCLAW_GATEWAY_TOKEN=your_token_here`
2.  **`openclaw.json`**: `gateway.auth.token: "your_token_here"`

If these are not synchronized, clients (like the Control UI) will fail to connect with authentication errors.

## Configuration Validation
OpenClaw uses a strict JSON schema. If the gateway fails to start, run the doctor:
```bash
oc fix
```
This runs `openclaw doctor --fix` inside the container to prune unrecognized keys and fix schema deprecations.

## Backups & Persistence
*   **Time Machine Backups (Automated):** A daily cron job runs at 03:30 AM to create timestamped snapshots.
    - **Location:** `<USER_HOME>/openclaw_backups/`
    - **Retention Policy:**
        - `daily/`: 7 days of daily snapshots
        - `weekly/`: 4 weeks of weekly (Monday) snapshots
        - `monthly/`: 6 months of monthly (1st of month) snapshots
    - **Script:** `<PROJECT_ROOT>/backup_timemachine.sh`
*   **Agent Identity:** The agent configuration is stored in the Docker volume.
*   **Workspace Data:** Stored on the host at `<PROJECT_ROOT>/sandbox_data`. Back up this directory to save agent files and Warden logs.
*   **Configuration Backup:** A copy of the agent's config is automatically synced to `<PROJECT_ROOT>/sandbox_data/openclaw_backup`.

## Logs & Debugging
*   **Warden Logs:** `docker logs -f warden_sentry`
*   **Agent Logs:** `docker logs -f openclaw_vm`
*   **System Logs (Docker):** `journalctl -u docker -f`
*   **Clock Accuracy:** `chronyc tracking` (Run monthly to ensure NTP is healthy).
*   **WSS Fingerprint:** To retrieve the current gateway fingerprint:
    `docker exec openclaw_vm openssl x509 -noout -fingerprint -sha256 -in /home/prisoner/.openclaw/gateway/tls/gateway-cert.pem`

## Updates (oc upgrade)
The sandbox uses a simplified **Surgical Upgrade** process.
1.  **Safety Check**: Run `oc upgrade`. The script will verify a Time Machine backup exists from the last 24 hours.
2.  **Live Rebuild**: If verified, it will rebuild the `openclaw` container without cache to fetch the latest NPM version.
3.  **Auto-Heal**: It automatically runs `openclaw doctor --fix` post-update.

To manually trigger a backup before upgrading:
```bash
bash backup_timemachine.sh
```

## Updates (Registry-Based)
Components pulled from Docker Hub (like Airlock/FileBrowser) are updated automatically by **Watchtower**.

## Common Issues
*   **Network Failure:** Check `iptables -L FORWARD`. If the bridge ID changed (e.g., after `docker network prune`), re-run the manual isolation rules.
*   **Agent Crash:** Check logs for "Unknown model" or missing API keys. Verify `.env` file matches `docker-compose.yml`.
