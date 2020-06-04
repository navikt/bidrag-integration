const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const ghPage = core.getInput('github_page');
    const passed = core.getInput('passed');
    const failed = core.getInput('failed');
    const pagesFolder = core.getInput('ghp_folder');

    core.info(
        `ghPage "${ghPage}", passed "${passed}", failed "${failed}", pagesFolder "${pagesFolder}"`
    );

    // Execute bash script
    await exec.exec(
        `bash ${__dirname}/../status.sh "${ghPage}" "${passed}" "${failed}" "${pagesFolder}"`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
