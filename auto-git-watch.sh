#!/usr/bin/env bash

# Directory to watch
WATCH_DIR="/var/www/halomom-assets"

# Remote branch to push to (change if needed)
REMOTE_NAME="origin"
BRANCH_NAME="main"

cd "$WATCH_DIR" || {
  echo "Failed to cd into $WATCH_DIR"
  exit 1
}

if ! command -v inotifywait >/dev/null 2>&1; then
  echo "The 'inotifywait' command is required but not installed."
  echo "On Debian/Ubuntu, install it with: sudo apt-get install inotify-tools"
  exit 1
fi

echo "Watching $WATCH_DIR for changes. Press Ctrl+C to stop."

while true; do
  # Wait for any change in the directory tree
  inotifywait -r -e create,modify,delete,move "$WATCH_DIR" >/dev/null 2>&1

  # Small debounce delay to batch rapid changes
  sleep 2

  # Add all changes
  git add -A

  # Commit only if there is something to commit
  if ! git diff --cached --quiet; then
    COMMIT_MESSAGE="Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Committing changes: $COMMIT_MESSAGE"
    git commit -m "$COMMIT_MESSAGE"

    echo "Pushing to $REMOTE_NAME/$BRANCH_NAME..."
    git push "$REMOTE_NAME" "$BRANCH_NAME"
  fi
done


