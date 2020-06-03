const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const filepath = core.getInput('relative_filepath');
    const jsonPath = core.getInput('json_path');

    // Execute tag bash script
    await exec.exec(
        `bash ${__dirname}/../report.sh "${filepath}" "${jsonPath}"`
    );

  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
