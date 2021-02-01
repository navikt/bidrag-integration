const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const applications = core.getInput('applications')
    const jsonRelativePath = core.getInput('json_relative_path')
    const naisProjectFolder = core.getInput('nais_project_folder')
    const testUsername = core.getInput('test_username')

    // Execute create-integration-input bash script
    await exec.exec(
        `${__dirname}/../create-integration-input.sh`,
        [applications, jsonRelativePath, naisProjectFolder, testUsername]
    );
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
