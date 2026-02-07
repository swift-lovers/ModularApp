#!/bin/sh

# Check if RepoSync folder exists
if [ ! -d "RepoSync" ]; then
  echo "❌ Error: The 'RepoSync' folder does not exist."
  exit 1
fi

# Run the RepoSync plugin
swift package --package-path RepoSync plugin RepoSync --allow-writing-to-package-directory --allow-writing-to-directory . --allow-network-connections all "$@"
