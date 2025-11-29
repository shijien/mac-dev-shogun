#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
  echo "Usage: ./tag_release.sh <version>"
  echo "Example: ./tag_release.sh 1.0.0"
  exit 1
fi

VERSION="$1"
TAG="v$VERSION"

echo "Tagging release: $TAG"

# Optional: ensure working tree is clean
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️ Working tree is dirty."
  echo "Commit or stash your changes before tagging."
  git status
  exit 1
fi

# Create tag and push
git tag -a "$TAG" -m "Release $TAG"
git push origin "$TAG"

echo "✅ Created and pushed tag $TAG"
echo "Next:"
echo "  1. Wait for GitHub Actions release-helper job to compute SHA256"
echo "  2. Update mac-dev-shogun.rb with the new url + sha256"
echo "  3. Commit and push formula changes"
