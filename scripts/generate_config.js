const fs = require('fs');

const config = {
  "meta": {
    "lastTouchedVersion": "2026.2.6-3",
    "lastTouchedAt": new Date().toISOString()
  },
  "wizard": {
    "lastRunAt": "2026-02-08T13:37:09.748Z",
    "lastRunVersion": "2026.2.6-3",
    "lastRunCommand": "onboard",
    "lastRunMode": "local"
  },
  "auth": {
    "profiles": {
      "openrouter:default": { "provider": "openrouter", "mode": "api_key" },
      "google:default": { "provider": "google", "mode": "api_key" },
      "google:manual": { "provider": "google", "mode": "token" },
      "openai:default": { "provider": "openai", "mode": "api_key" },
      "deepseek:default": { "provider": "deepseek", "mode": "api_key" },
      "deepseek:manual": { "provider": "deepseek", "mode": "token" }
    }
  },
  "agents": {
    "defaults": {
      "model": { "primary": "deepseek-chat" },
      "models": {
        "openrouter/auto": { "alias": "OpenRouter" },
        "google/gemini-3-flash-preview": { "alias": "gemini-flash" },
        "deepseek-chat": { "alias": "DeepSeek" }
      },
      "workspace": "/app/workspace",
      "compaction": { "mode": "safeguard" },
      "maxConcurrent": 4,
      "subagents": { "maxConcurrent": 8 }
    }
  },
  "messages": { "ackReactionScope": "group-mentions" },
  "commands": { "native": "auto", "nativeSkills": "auto" },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "groupPolicy": "allowlist",
      "streamMode": "partial"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "b5440a9c6de39d02a1db771d67816f85a584a5f6c4c8d81b"
    },
    "tailscale": { "mode": "off", "resetOnExit": false }
  },
  "skills": { "install": { "nodeManager": "npm" } },
  "plugins": { "entries": { "telegram": { "enabled": true } } },
  "models": {
    "providers": {
      "deepseek": {
        "provider": "openai",
        "baseUrl": "https://api.deepseek.com/v1",
        "apiKey": "sk-2154090557184e088a34b17fa6790c36",
        "models": [
          { "id": "deepseek-chat" },
          { "id": "deepseek-reasoner" }
        ]
      }
    }
  }
};

fs.writeFileSync('openclaw-lab/openclaw.json', JSON.stringify(config, null, 2));
console.log('Generated new openclaw.json');
