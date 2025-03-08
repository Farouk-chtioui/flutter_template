// scripts/applyConfig.js
const fs = require('fs');
const path = require('path');

const configPath = process.argv[2];
if (!configPath || !fs.existsSync(configPath)) {
  console.error('Configuration file not found.');
  process.exit(1);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

// Example: Write OTA pack JSON files based on the configuration.
// Adjust this script to suit your needs—for instance, update Dart config files, etc.
const otaPacks = {
  design: config.appDesign || {},
  layout: config.appLayout || {},
  screens: config.screens || [],
  onboarding: config.onboardingScreens || [],
  config: {
    ...config.mobileApp,
    _id: config.mobileApp && config.mobileApp._id ? String(config.mobileApp._id) : undefined,
  },
};

// Ensure the OTA packs directory exists
const packsDir = path.join(process.cwd(), 'assets', 'ota_packs');
if (!fs.existsSync(packsDir)) {
  fs.mkdirSync(packsDir, { recursive: true });
}

Object.entries(otaPacks).forEach(([packName, packData]) => {
  fs.writeFileSync(
    path.join(packsDir, `${packName}_pack.json`),
    JSON.stringify(packData, null, 2),
    'utf8'
  );
});

console.log('Configuration applied successfully.');
