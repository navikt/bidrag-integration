const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const pagesAddress = core.getInput('pages_address');
    const projectWhereToMove = core.getInput('project_where_to_move');

    // Execute tag bash script
    await exec.exec(
        `bash ${__dirname}/../report.sh "${pagesAddress}" "${projectWhereToMove}"`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
