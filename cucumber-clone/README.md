### Cloning credentials

When cloning extra projects from github, a security token must be provided.

The environment variable `EXTRA_CLONES_CREDENTIALS` must be present when the property
`extra_clones` is given.

The value of this variable should be `: "<github username>:<personal access token>`
