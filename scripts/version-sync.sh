#!/bin/bash
set -e

# Get version from git tag
VERSION=${1:-$(git describe --tags --abbrev=0)}

# Update Chart.yaml
yq -i ".version = \"$VERSION\"" charts/authentik/Chart.yaml
yq -i ".appVersion = \"$VERSION\"" charts/authentik/Chart.yaml

echo "Updated chart version to $VERSION"