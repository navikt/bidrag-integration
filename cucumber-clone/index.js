const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  const cucumberProject = core.getInput('cucumber_project')
  const folderNaisApps = core.getInput('folder_nais_apps')
  const extraClones = core.getInput('extra_clones')
  const delimiter = core.getInput('delimiter')

  try {
    // Execute cucumber-clone bash script
    await exec.exec(
        `${__dirname}/../cucumber-clone.sh`,
        [cucumberProject, folderNaisApps, extraClones, delimiter]
    );
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
