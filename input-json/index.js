const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const applications = core.getInput('applications')

    // Execute create-integration-input bash script
    await exec.exec(
        `${__dirname}/../create-integration-input.sh`, [applications]
    );
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
