const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const folderMoveFrom = core.getInput('folder_move_from');
    const projectWhereToMove = core.getInput('project_where_to_move');
    const frontPage = core.getInput('front_page');
    const latestCucumberJson = core.getInput('latest_cucumber_json');

    // Execute tag bash script
    await exec.exec(
        `bash ${__dirname}/../move.sh`,
        [folderMoveFrom, projectWhereToMove, frontPage, latestCucumberJson]
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
