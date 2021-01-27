const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const nais_apps_folder = core.getInput('nais_apps_folder')

    // Execute cucumber-clone-tags bash script
    await exec.exec(
        `${__dirname}/../cucumber-clone-tags.sh`, [nais_apps_folder]
    );
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
