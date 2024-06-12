const fs = require('fs');
const path = require('path');
const YAML = require('yaml'); // Import the YAML package

const config = require('./configurations.json');

const generateConfigFiles = (config) => {
    const sharedDir = path.join(__dirname, 'languages', 'shared');
    const languagesDir = path.join(__dirname, 'languages');

    // Ensure directories exist
    if (!fs.existsSync(sharedDir)) {
        fs.mkdirSync(sharedDir, {recursive: true});
    }

    // Write common configuration
    fs.writeFileSync(path.join(sharedDir, 'common.yaml'), YAML.stringify(config.shared.common));

    // Write individual language configurations
    for (const [language, settings] of Object.entries(config.languages)) {
        const languageConfig = {
            '!include': 'shared/common.yaml',
            ...settings,
        };
        fs.writeFileSync(path.join(languagesDir, `${language}.yaml`), YAML.stringify(languageConfig));
    }
};

generateConfigFiles(config);
