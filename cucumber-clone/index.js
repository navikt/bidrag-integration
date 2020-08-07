const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  const cucumberProject = core.getInput('cucumber_project')
  const folderNaisApps = core.getInput('folder_nais_apps')

  try {
    // Execute cucumber-clone bash script
    await exec.exec(
        `${__dirname}/../cucumber-clone.sh`,
        [cucumberProject, folderNaisApps]
    );
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
