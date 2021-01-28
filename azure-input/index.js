const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const applications = core.getInput('applications')

    // Execute cucumber-clone-tags bash script
    await exec.exec(
        `${__dirname}/../createAzureInput.sh`, [applications]
    );
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
