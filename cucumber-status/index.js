const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const ghPage = core.getInput('github_page');
    const passed = core.getInput('passed');
    const failed = core.getInput('failed');
    const proName = core.getInput('project_name');
    const pagesFolder = core.getInput('ghp_folder');

    core.info(
        `ghPage "${ghPage}", passed "${passed}", failed "${failed}", proName "${proName}", pagesFolder "${pagesFolder}"`
    );

    // Execute bash script
    await exec.exec(
        `bash ${__dirname}/../status.sh "${ghPage}" "${passed}" "${failed}" "${proName}" "${pagesFolder}"`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
