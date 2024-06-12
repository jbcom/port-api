import globals from "globals";
import pluginJs from "@eslint/js";

export default [
    {
        languageOptions: {
            globals: {
                ...globals.browser,
                ...globals.node,
                ...globals.mocha, // Add Mocha globals
            },
            ecmaVersion: 2021, // Use the latest ECMAScript syntax
            sourceType: "module", // Support ECMAScript modules
        },
    },
    pluginJs.configs.recommended,
];
