const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const naisApps = core.getInput('nais-apps');

    // Execute bash script
    await exec.exec(`bash ${__dirname}/../apps.sh`, [naisApps]);

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
