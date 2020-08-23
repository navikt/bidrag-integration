const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const pagesAddress = core.getInput('pages_address');
    const githubPagePath = core.getInput('path_github_page');

    // Execute bash script
    await exec.exec(
        `bash ${__dirname}/../report.sh`, [pagesAddress, githubPagePath]
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
