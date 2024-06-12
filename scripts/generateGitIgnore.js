const {exec} = require('child_process');
const languages = require('./config/languages');

const additionalGitignores = [
    'Windows',
    'macOS',
    'Linux',
    'VisualStudioCode',
    'SublimeText',
    'JetBrains'
];

const gitignoreLanguages = [
    ...Object.values(languages).map(lang => lang.gitignore),
    ...additionalGitignores
].join(',');

exec(`npx add-gitignore ${gitignoreLanguages}`, (error, stdout, stderr) => {
    if (error) {
        console.error(`Error generating .gitignore: ${stderr}`);
        process.exit(1);
    }
    console.log(`.gitignore generated successfully for languages: ${gitignoreLanguages}`);
    console.log(stdout);
});
