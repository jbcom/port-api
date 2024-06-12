const fs = require("fs");
const path = require("path");
const { Configuration, OpenAIApi } = require("openai");
const { encode } = require("gpt-3-encoder"); // Import the encoder
const languages = require("./config/languages"); // Import languages configuration
require("dotenv").config();

const configuration = new Configuration({
  apiKey: process.env.OPENAI_API_KEY,
});
const openai = new OpenAIApi(configuration);

const MAX_TOKENS = 4096; // Maximum tokens for GPT-4 Turbo

const calculateMaxTokens = (inputText) => {
  const inputTokens = encode(inputText).length;
  // Reserving tokens for the prompt itself, as it will consume some tokens
  return Math.max(0, MAX_TOKENS - inputTokens - 500); // Reserve 500 tokens for safety
};

const generateTests = async (language, code) => {
  const prompt = `
  You are a software testing assistant. Your task is to generate unit tests for the provided ${languages[language].openapi} code. 
  The project involves creating a comprehensive set of clients for interacting with the Port API. 
  These clients enable developers to seamlessly integrate their applications with the Port API, facilitating the management and automation of their software catalog.

  Please generate unit tests that cover the following aspects:
  1. Basic functionality and correct outputs.
  2. Edge cases and error handling.
  3. Integration with other components if applicable.

  Here is the ${languages[language].openapi} code that needs unit tests:
  \n${code}\n`;

  const maxTokens = calculateMaxTokens(prompt);

  try {
    const response = await openai.createChatCompletion({
      model: "gpt-4-turbo",
      messages: [
        { role: "system", content: "You are a helpful assistant." },
        { role: "user", content: prompt },
      ],
      max_tokens: maxTokens,
    });

    return response.data.choices[0].message.content;
  } catch (error) {
    console.error(
      `Error generating tests for ${languages[language].openapi}:`,
      error,
    );
  }
};

const main = async () => {
  const [, , language, filePath] = process.argv;

  if (!languages[language]) {
    console.error(`Unsupported language: ${language}`);
    process.exit(1);
  }

  if (!filePath) {
    console.error("File path is a required parameter.");
    process.exit(1);
  }

  const code = fs.readFileSync(filePath, "utf-8");
  const tests = await generateTests(language, code);

  const testFilePath = filePath.replace(`.${language}`, `.test.${language}`);
  fs.mkdirSync(path.dirname(testFilePath), { recursive: true });
  fs.writeFileSync(testFilePath, tests);
  console.log(`Generated tests for ${filePath}`);
};

main();

module.exports = { generateTests };
