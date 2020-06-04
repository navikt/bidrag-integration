const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const frontPage = core.getInput('frontPage');
    const passed = core.getInput('passed');
    const failed = core.getInput('failed');
    const pagesFolder = core.getInput('ghp_folder');

    // Execute tag bash script
    await exec.exec(
        `bash ${__dirname}/../status.sh "${frontPage}" "${passed}" "${failed}" "${pagesFolder}"`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
