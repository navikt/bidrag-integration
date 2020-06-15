const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const linkPages = core.getInput('link_pages');
    const pagePath = core.getInput('page_path');
    const pattern = core.getInput('pattern');

    // Execute bash script
    await exec.exec(
        `bash ${__dirname}/../link.sh"`,
        [linkPages, pagePath, pattern]
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
