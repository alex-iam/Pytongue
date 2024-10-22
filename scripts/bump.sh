#!/bin/bash

VERSION_FILE="./version"

# Check if version file exists
if [ ! -f "$VERSION_FILE" ]; then
    echo "Error: version file not found at $VERSION_FILE"
    exit 1
fi

# Read current version
VERSION=$(cat "$VERSION_FILE")

# Validate version format (x.y.z)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid version format in $VERSION_FILE. Expected x.y.z"
    exit 1
fi

# Split version into components
IFS='.' read -r major minor patch <<< "$VERSION"

# Check argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 [major|minor|patch]"
    exit 1
fi

case "$1" in
    "major")
        major=$((major + 1))
        minor=0
        patch=0
        ;;
    "minor")
        minor=$((minor + 1))
        patch=0
        ;;
    "patch")
        patch=$((patch + 1))
        ;;
    *)
        echo "Error: Invalid argument. Use major, minor, or patch"
        exit 1
        ;;
esac

# Construct new version
NEW_VERSION="${major}.${minor}.${patch}"

# Write new version to file
echo "$NEW_VERSION" > "$VERSION_FILE"
echo "Version bumped to $NEW_VERSION"