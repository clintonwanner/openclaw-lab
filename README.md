# 🦞 OpenClaw Lab: The Ironclad Sandbox Stack

OpenClaw Lab is a robust, security-first orchestration environment for autonomous AI agents. It provides a containerized "Prisoner" runtime for agents, monitored by a "Warden" security sidecar, ensuring that code generation and execution remain isolated and safe.

## 🛡️ Core Architecture

- **The Prisoner (OpenClaw VM)**: A hardened Docker container where the AI agent lives and works. It has restricted network access and strictly limited system capabilities.
- **The Warden (Security Sidecar)**: A dedicated container running real-time malware scanning (ClamAV) and file-integrity monitoring on the agent's workspace.
- **The Dispatcher (oc CLI)**: A host-level management tool for starting, stopping, and configuring the entire stack.

## 🚀 Getting Started

### 1. Prerequisites
- **Docker & Docker Compose**: V2.x+ recommended.
- **Linux**: Optimized for Ubuntu/Pop!_OS (systemd support required for service mode).
- **System Utilities**: `jq`, `curl`, and `bash`.
- **LLM API Keys**: At least one key from NVIDIA, Gemini, DeepSeek, or OpenRouter.

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/<YOUR_ORGS>/openclaw-lab.git
cd openclaw-lab

# Initialize environment
cp .env.example .env
# Edit .env and fill in your API_KEYs and tokens
```

### 3. Initial Configuration
Before starting the stack, ensure you have initialized your "Source of Truth" templates:
```bash
mkdir -p sandbox_data/openclaw_config
# The stack will auto-generate base configs on first boot
```

## 🛠️ The `oc` CLI

The `oc` binary is your command center. It is located in `bin/oc`.

### Core Commands
| Command | Description |
| :--- | :--- |
| `./bin/oc up` | Starts the Docker containers and network rules. |
| `./bin/oc down` | Stops the stack and tears down isolation rules. |
| `./bin/oc status` | Shows container health, resources, and the active LLM model. |
| `./bin/oc logs` | Tails the real-time gateway logs. |
| `./bin/oc fix` | Runs the internal `doctor` and repairs configuration desyncs. |
| `./bin/oc auth` | Starts the interactive Google Workspace OAuth flow. |

### Configuration Sub-commands
Use `./bin/oc config [sub]` for live updates:
- **`model`**: Interactively switch the primary LLM model.
- **`provider`**: Add or switch between AI providers (NVIDIA, OpenRouter, etc.).
- **`key`**: Manage API keys in your `.env` and Docker environment.
- **`status`**: View the current configuration sync state.

## 🤖 Agent Orchestration

OpenClaw Lab uses a "Source of Truth" architecture. Agents are defined by markdown files in `templates/` which are symlinked into their workspaces.

- **[SOUL.md](templates/SOUL.md)**: The "Deterministic Execution" protocol.
- **[AGENTS.md](templates/AGENTS.md)**: Defines roles like `coder` (read/write) and `researcher` (read-only).
- **[USER.md](templates/USER.md)**: Your personal identity and security posture.

### Example Workflow: Research & Implement
1.  **Researcher**: Scans the web for a new library documentation.
2.  **Coder**: Generates a test suite and implementation based on the research.
3.  **Reviewer**: Checks the code against `SECURITY.md` protocols before finalizing.

## 🔌 Google Workspace Integration
Authorize your agent to manage your productivity:
```bash
./bin/oc auth
```
*Supported services: Gmail, Calendar, Drive, Contacts, Sheets, Docs.*

## 📂 Documentation
- [Architecture Deep-Dive](docs/ARCHITECTURE.md)
- [Security Hardening](docs/SECURITY.md)
- [Maintenance & Backups](docs/MAINTENANCE.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

## ⚖️ License
Licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for details.

---
**Author & Maintainer:** Clinton Wanner
*OpenClaw Lab is an independent project built to orchestrate and harden OpenClaw-based agent environments.*
