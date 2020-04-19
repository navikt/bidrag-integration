const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const folderMoveFrom = core.getInput('folder_move_from');
    const folderForHtml = core.getInput('folder_for_html');

    // Execute tag bash script
    await exec.exec(
        `bash ${__dirname}/../move.sh "${folderMoveFrom}" "${folderForHtml}"`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
