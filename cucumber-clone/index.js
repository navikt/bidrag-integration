const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  const cucumberProject = core.getInput('cucumber_project')

  try {
    // Execute cucumber-clone bash script
    await exec.exec(`${__dirname}/../cucumber-clone.sh`, [cucumberProject]);
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
