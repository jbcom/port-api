const { exec } = require("child_process");
const path = require("path");
const fs = require("fs");
const chai = require("chai");
const chaiFs = require("chai-fs");

chai.use(chaiFs);
const { expect } = chai;

const outputDir = path.join(__dirname, "..", "clients");
const testDir = path.join(__dirname, "..", "tests", "generated");

describe("End-to-End Client and Test Generation", function () {
  this.timeout(300000); // Set timeout to 5 minutes to allow for client generation

  before((done) => {
    // Clean up output directories before running tests
    if (fs.existsSync(outputDir)) {
      fs.rmSync(outputDir, { recursive: true, force: true });
    }
    if (fs.existsSync(testDir)) {
      fs.rmSync(testDir, { recursive: true, force: true });
    }
    done();
  });

  it("should generate clients and corresponding tests", (done) => {
    exec("npm run generate:clients", (error, stdout, stderr) => {
      if (error) {
        console.error(`Error during generation: ${stderr}`);
        return done(error);
      }
      console.log(stdout);

      // Verify that clients were generated
      expect(outputDir)
        .to.be.a.directory()
        .with.subDirs(["typescript", "java", "python", "csharp", "go"]);

      // Verify that tests were generated for each client
      const langs = ["typescript", "java", "python", "csharp", "go"];
      langs.forEach((lang) => {
        const clientDir = path.join(outputDir, lang);
        const testFiles = fs
          .readdirSync(clientDir)
          .filter((file) =>
            file.endsWith(`.test.${lang === "typescript" ? "ts" : lang}`),
          );
        expect(testFiles.length).to.be.greaterThan(
          0,
          `No test files found for ${lang} client`,
        );

        // Execute the generated test files to ensure they are valid
        testFiles.forEach((testFile) => {
          const testFilePath = path.join(clientDir, testFile);
          exec(`node ${testFilePath}`, (error, stdout, stderr) => {
            if (error) {
              console.error(`Error executing test file ${testFile}: ${stderr}`);
              return done(error);
            }
            console.log(stdout);
            expect(stdout).to.include(
              "Test results",
              `Test file ${testFile} did not run correctly`,
            );
          });
        });
      });

      done();
    });
  });
});
