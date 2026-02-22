# Ironclad OpenClaw Sandbox

**Status:** Active & Hardened
**Last Updated:** February 18, 2026

## Overview
The **Ironclad Sandbox** is a "paranoid-level" execution environment designed to run an autonomous AI agent (`openclaw`) with zero trust for the host system. It employs **Container Isolation**, **Network Segmentation**, and **Active File Monitoring** to contain potential threats.

The system uses standard **Docker Containers** (`runc`) for maximum stability and performance, secured by rigorous host-level network restrictions and real-time filesystem monitoring. Hardware virtualization (Kata) was evaluated and officially excluded from the design to maintain a lean architecture.

## Quick Start

### Prerequisites
*   **OS:** Linux (Ubuntu/Pop!_OS)
*   **Runtime:** Docker Engine & Docker Compose

### Starting the Stack
The stack is managed via Docker Compose.

```bash
cd ~/openclaw-lab
docker compose up -d
# Apply/Verify network rules
bash run_network_rules
```

### Accessing the Interface
*   **Ironclad Agent (OpenClaw):** [http://localhost:18789](http://localhost:18789)
    *   *Control UI for the AI Agent.*
*   **Airlock (File Browser):** [http://localhost:8082](http://localhost:8082)
    *   *Default User:* `admin` / `admin12345678`
*   **Agent Workspace:** Mounted at `<PROJECT_ROOT>/sandbox_data` (on host).

## Persistence & Configuration
*   **Automated Management:** Configuration is managed via the **`oc config`** CLI, which ensures that API keys and model settings are synchronized between the host `.env` and the agent's `openclaw.json`.
*   **Identity & Identity:** The Agent's identity, Telegram pairings, and device approvals are stored in `sandbox_data/openclaw_config`. These are 100% persistent across container restarts.
*   **Workspace:** The Agent's work directory is bind-mounted to `sandbox_data/openclaw_config/workspace` (managed via the shared config volume), ensuring files and logs are physically saved to the host.
*   **Backups:** A "Gold Image" backup is maintained in `sandbox_data/openclaw_backup` for disaster recovery.

## Core Components

| Service | Name | Role | Technology |
| :--- | :--- | :--- | :--- |
| **The Prisoner** | `openclaw_vm` | The AI Agent | **Node:22-Bookworm** (Docker) |
| **The Warden** | `warden_sentry` | Security Sidecar | ClamAV + `inotify` |
| **The Airlock** | `airlock_gui` | File Transfer | FileBrowser (Web UI) |

## Documentation Index
*   [ARCHITECTURE.md](./ARCHITECTURE.md) - Deep dive into stack architecture.
*   [SECURITY.md](./SECURITY.md) - Network rules, Warden logic, and Threat Model.
*   [MAINTENANCE.md](./MAINTENANCE.md) - Operations and Updates.
*   [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - **Read here for Startup Crashes.**
