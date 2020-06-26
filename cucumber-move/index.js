const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const folderMoveFrom = core.getInput('folder_move_from');
    const projectWhereToMove = core.getInput('project_where_to_move');
    const frontPage = core.getInput('front_page');

    // Execute tag bash script
    await exec.exec(
        `bash ${__dirname}/../move.sh "${folderMoveFrom}" "${projectWhereToMove}" "${frontPage}"`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
