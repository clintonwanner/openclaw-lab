# Security Model

## Threat Model
The system assumes the **Prisoner (AI Agent)** is untrusted. It may attempt to:
1.  **Escalate Privileges:** Break out of the container to the host.
2.  **Lateral Movement:** Attack other devices on the LAN (NAS, Router).
3.  **Persist Malware:** Write malicious scripts to the shared volume.

## Defense Layers

### Layer 1: Container Isolation (The Cell)
*   **Technology:** Docker (`runc`).
*   **Effect:** The agent runs in a dedicated container namespace with restricted capabilities (`CAP_DROP=ALL`).
*   **Decision:** Hardware virtualization (Kata/Firecracker) was evaluated and decoped to ensure system stability and performance. Isolation is instead layered via network and filesystem controls.

### Layer 2: Network Segmentation (The Moat)
*   **Technology:** Docker Bridge + `iptables`.
*   **Effect:** The Agent can talk to the internet (OpenAI/OpenRouter APIs) but cannot send packets to `192.168.x.x`, `10.x.x.x`, or `172.16.x.x`.
*   **Reliability:** The Gateway is bound to `loopback` internally. This allows the internal agent to bypass the "Moat" rules for its own management traffic, while external attacks on other LAN devices remain blocked.
*   **Status:** **ACTIVE**. Rules are applied to the bridge interface dynamically.

### Layer 2.5: Secure Transmission (The Vault)
*   **Technology:** Native TLS (WSS).
*   **Effect:** All data between the Human (Dashboard/CLI) and the Agent is encrypted via `wss://`. 
*   **Trust:** Uses a self-signed RSA-2048 certificate with SHA-256 fingerprint verification.

### Layer 3: Active Monitoring (The Warden)
*   **Technology:** Sidecar Container + `inotify` + ClamAV.
*   **Effect:** Any file written to the shared volume (`<PROJECT_ROOT>/sandbox_data`) is instantly scanned.
*   **Optimization:** Transient `.tmp` files are excluded from active scanning to prevent race conditions during atomic write operations (common in OpenClaw's persistence layer).
*   **Reaction:**
    *   **Detection:** `clamdscan` identifies signature.
    *   **Quarantine:** File is moved to `/jail` (inaccessible to Agent).
    *   **Tombstone:** A text file explains the action to the Agent ("File quarantined due to virus...").

### Layer 4: Minimal Attack Surface
*   **Base Image:** Debian Bookworm Slim (Agent) - reduced footprint.
*   **Capabilities:** `CAP_DROP=ALL` (Enforced in `docker-compose.yml`).
*   **User:** Agent runs as root inside container but capability-stripped.

## Residual Risks
*   **Kernel Exploits:** Since containers share the host kernel, a zero-day kernel exploit could theoretically allow breakout. This is the trade-off for not using Firecracker.
*   **Resource Exhaustion:** `cpus` and `memory` limits are strictly enforced by Docker to mitigate DoS attempts.
