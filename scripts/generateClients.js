const { exec } = require("child_process");
const path = require("path");
const languages = require("./config/languages");
require("dotenv").config();

const openApiSpecPath = path.join(__dirname, "..", "openapi.json");
const outputDir = path.join(__dirname, "..", "clients");

const generateClients = () => {
  Object.keys(languages).forEach((lang) => {
    const command = `openapi-generator-cli generate -i ${openApiSpecPath} -g ${languages[lang].openapi} -o ${outputDir}/${lang}`;
    exec(command, (err, stdout, stderr) => {
      if (err) {
        console.error(`Error generating client for ${lang}:`, stderr);
      } else {
        console.log(`Client for ${lang} generated successfully:\n`, stdout);
      }
    });
  });
};

generateClients();
