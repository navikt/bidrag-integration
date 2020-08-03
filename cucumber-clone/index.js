const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    // Execute cucumber-clone bash script
    await exec.exec(`${__dirname}/../cucumber-clone.sh`);
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
