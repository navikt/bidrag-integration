const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const pagesAddress = core.getInput('pages_address');

    // Execute tag bash script
    await exec.exec(`bash ${__dirname}/../reports.sh "${pagesAddress}"`);

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
