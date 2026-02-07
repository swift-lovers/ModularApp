#!/bin/bash

echo "🔧 Installing git hooks..."

# Set hooks path for the main repo
git config core.hooksPath ./git-hooks
echo "✅ Git hooks installed for main repo."

# Set hooks path for each module repo
for dir in ModularApp-*/; do
  if [ -d "$dir/.git" ]; then
    git -C "$dir" config core.hooksPath ../git-hooks
    echo "✅ Git hooks installed for $dir"
  fi
done

echo "🎉 Done!"
