### Installation

Install the CLI globally:

- `npm install --save-dev release-please@15`
- `npm

Check official documentation [here](https://github.com/googleapis/release-please/blob/main/docs/cli.md)

### Bootstrap

To init required config and manifest files run command:

```bash
release-please bootstrap \
  --token=$GITHUB_TOKEN \
  --repo-url=<owner>/<repo-name> \
  --release-type=node
```

Notes:

- Do not include `.git` in the repository name
- The repository must already exist and contain at least one commit

After running this command, the following files will be created:

- `.release-please-config.json`
- `.release-please-manifest.json`

You can set initial version in `.release-please-manifest.json` to match your `package.json` version.

You can change default config in `release-please-config.json`:

- `include-v-in-tag:true/false` - add `v` prefix to tags
- `changelog-path` - default is `CHANGELOG.md`

### Release Pull Request

To generate CHANGELOG.md, and bump version, run this command:

```bash
release-please release-pr \
  --token=$GITHUB_TOKEN \
  --repo-url=<owner>/<repo-name>
```

This step:

- Creates `CHANGELOG.md`
- Updates version in `package.json` and `package-lock.json`
- Updates version in `.release-please-manifest.json`

### Release

After the release PR is approved and merged, create a GitHub release and tag:

```bash
release-please github-release \
  --token=$GITHUB_TOKEN \
  --repo-url=<owner>/<repo-name>
```

This step:

- Creates a Git tag (e.g. v1.2.3)
- Publishes a GitHub release

Creating a GitHub release does NOT publish to npm.

### Additional set-up

`npm install dotenv-cli --save-dev`

Add to `package.json`

```json
{
  "scripts": {
    "release:bootstrap": "dotenv -e .env.release -- sh -c 'release-please bootstrap --token=$GITHUB_TOKEN --repo-url=$REPO --release-type=node'",
    "release:pr": "dotenv -e .env.release -- sh -c 'release-please release-pr --token=$GITHUB_TOKEN --repo-url=$REPO'",
    "release:github": "dotenv -e .env.release -- sh -c 'release-please github-release --token=$GITHUB_TOKEN --repo-url=$REPO'"
  }
}
```

Add to .env.release

```env
GITHUB_TOKEN=your_token
REPO=owner/repo-name
```

### Workflow

Regular feature:

- `feature-branch` -squash-pr-> `dev`
- `dev` -merge-pr-> `qa`
- `qa` -merge-pr-> `main`

Hotfix:

- `hotfix-branch` -squash-pr-> `main` (`dev` should be in sync)

Release:

- run `npm run release:pr`
- approve and merge release PR
- run `npm run release:github`

Note:
Pull Request titles and commit messages in dev/qa/main branches should follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification for automatic versioning to work properly.

### GitHub Action

Minimal setup ([docs](https://github.com/googleapis/release-please-action)):

```yaml
on:
  push:
    branches:
      - main

permissions:
  contents: write
  issues: write
  pull-requests: write

name: release-please

jobs:
  release-please:
    runs-on: ubuntu-slim
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          release-type: node
```

This action:

- Triggers on new push to main (or pr merge)
- Creates Release PR with version bump and CHANGELOG.md
- After the PR is approved, creates new GitHub release and tag.

Note: Git hub actions should be allowed to create and edit pull requests (github repo settings/actions)

### PR Title Validation Action

```yaml
name: Validate PR Title
on:
  pull_request:
    branches:
      - dev
      - qa
      - main
    types: [opened, edited, synchronize, reopened]

jobs:
  pr-title:
    name: PR Title Check
    runs-on: ubuntu-latest
    steps:
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

By default follows [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.
