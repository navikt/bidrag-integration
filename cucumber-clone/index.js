const core = require("@actions/core");
const exec = require("@actions/exec");

async function run() {
  try {
    const naisGithubProject = core.getInput('nais_github_project');

    // Execute cucumber-clone bash script
    await exec.exec(`${__dirname}/../cucumber-clone.sh`, [naisGithubProject]);
  } catch (error) {
    core.setFailed(error.message);
  }
}

// noinspection JSIgnoredPromiseFromCall
run();
