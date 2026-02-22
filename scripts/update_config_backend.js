const fs = require('fs');
const path = require('path');

const configPath = '/root/.openclaw/openclaw.json';
const authProfilesPath = '/root/.openclaw/agents/main/agent/auth-profiles.json';
const geminiKey = '<YOUR_GEMINI_API_KEY>';
const defaultModel = 'google/gemini-3-flash-preview';

// Update auth-profiles.json
let authProfiles = {};
if (fs.existsSync(authProfilesPath)) {
    authProfiles = JSON.parse(fs.readFileSync(authProfilesPath, 'utf8'));
}
authProfiles['google:default'] = {
    provider: 'google',
    mode: 'api_key',
    apiKey: geminiKey
};
fs.writeFileSync(authProfilesPath, JSON.stringify(authProfiles, null, 2));
console.log('Updated auth-profiles.json');

// Update openclaw.json
if (fs.existsSync(configPath)) {
    let config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    
    // Add google to auth profiles
    if (!config.auth) config.auth = { profiles: {} };
    if (!config.auth.profiles) config.auth.profiles = {};
    config.auth.profiles['google:default'] = {
        provider: 'google',
        mode: 'api_key'
    };
    
    // Set default model
    if (!config.agents) config.agents = { defaults: {} };
    if (!config.agents.defaults) config.agents.defaults = {};
    if (!config.agents.defaults.model) config.agents.defaults.model = {};
    config.agents.defaults.model.primary = defaultModel;
    
    // Ensure the model is in the models list
    if (!config.agents.defaults.models) config.agents.defaults.models = {};
    config.agents.defaults.models[defaultModel] = {};
    
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    console.log('Updated openclaw.json');
} else {
    console.error('openclaw.json not found at ' + configPath);
}
