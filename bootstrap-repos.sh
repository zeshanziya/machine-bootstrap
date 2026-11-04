#!/usr/bin/env bash
# Clone claude-helpers into the standard project layout (SSH).
#
# On a virgin Mac, run this before anything else is cloned:
#   curl -fsSL https://raw.githubusercontent.com/zeshanziya/machine-bootstrap/main/bootstrap-repos.sh | bash
# (Requires step 0 of mac-old/README.md first: Xcode CLT + 1Password SSH agent signed in.)
#
# Idempotent: existing clones are skipped.
set -euo pipefail

PROJECTS_DIR="$HOME/Documents/work-area/personal/projects"
REPOS=(
  "git@github.com:zeshanziya/claude-helpers.git"
)

command -v git >/dev/null 2>&1 || { echo "ERROR: git not found — install Xcode Command Line Tools first (xcode-select --install)"; exit 1; }

if ! ssh -T git@github.com -o BatchMode=yes -o StrictHostKeyChecking=accept-new 2>&1 | grep -q "successfully authenticated"; then
  echo "ERROR: SSH auth to github.com failed — sign in to 1Password and enable its SSH agent first (mac-old/README.md step 0)"
  exit 1
fi

mkdir -p "$PROJECTS_DIR"

for repo in "${REPOS[@]}"; do
  name=$(basename "$repo" .git)
  dest="$PROJECTS_DIR/$name"
  if [ -d "$dest/.git" ]; then
    echo "OK:   $name (already cloned at $dest)"
  else
    echo "CLONE: $repo -> $dest"
    git clone "$repo" "$dest"
  fi
done

echo ""
echo "=== Done ==="
echo "Next: cd $PROJECTS_DIR/claude-helpers && ./scripts/new-machine.sh"
