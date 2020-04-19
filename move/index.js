const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const folderMoveFrom = core.getInput('folder_move_from');
    const folderCopy = core.getInput('folder_copy');

    // Execute tag bash script
    await exec.exec(
        `bash ${__dirname}/../move.sh "${folderMoveFrom}" "${folderCopy}"`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
