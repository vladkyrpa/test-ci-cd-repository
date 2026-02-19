#!/bin/bash
source .env

# before run:
# npm install -g release-please

release-please github-release \
  --token=$GITHUB_TOKEN \
  --repo-url=your-org/your-repo \
  --config-file=release-please-config.json \
  --manifest-file=.release-please-manifest.json