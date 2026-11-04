#!/usr/bin/env bash
# Step 0 for a virgin Mac — needs NO auth, NO clone. Run it first:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/zeshanziya/machine-bootstrap/main/bootstrap-mac.sh)"
#
# Installs Homebrew (which brings the Xcode Command Line Tools), persists brew
# in ~/.zprofile so every new shell has it, and installs 1Password + its CLI
# via brew (so the Brewfile never needs `--adopt`). Idempotent.
#
# Then: sign in to 1Password, enable Settings > Developer > "Integrate with
# 1Password CLI" + SSH agent, and run scripts/bootstrap-repos.sh (SSH clones).
set -euo pipefail

if command -v brew >/dev/null 2>&1; then
  echo "OK:   Homebrew already installed"
else
  echo "INST: Homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apple Silicon path first, Intel fallback
BREW_BIN=/opt/homebrew/bin/brew
[ -x "$BREW_BIN" ] || BREW_BIN=/usr/local/bin/brew
eval "$("$BREW_BIN" shellenv)"

ZPROFILE="$HOME/.zprofile"
if [ -f "$ZPROFILE" ] && grep -q 'brew shellenv' "$ZPROFILE"; then
  echo "OK:   brew shellenv already in ~/.zprofile"
else
  echo "ADD:  brew shellenv -> ~/.zprofile"
  # shellcheck disable=SC2016  # $(...) must be written literally for zsh to evaluate later
  printf '\neval "$(%s shellenv zsh)"\n' "$BREW_BIN" >> "$ZPROFILE"
fi

for cask in 1password 1password-cli; do
  if brew list --cask "$cask" >/dev/null 2>&1; then
    echo "OK:   $cask"
  else
    echo "INST: $cask"
    brew install --cask "$cask"
  fi
done

# Point ssh at the 1Password SSH agent (the app-side toggle still has to be
# enabled by hand: Settings > Developer > "Use the SSH agent").
SSH_CONFIG="$HOME/.ssh/config"
# shellcheck disable=SC2088  # ssh expands ~ in IdentityAgent itself; keep it literal in the config
OP_AGENT='~/Library/Group Containers/2BUA8C4S2C.group.com.1password/t/agent.sock'
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
if grep -qs 'group.com.1password/t/agent.sock' "$SSH_CONFIG"; then
  echo "OK:   1Password IdentityAgent already in ~/.ssh/config"
else
  echo "ADD:  1Password IdentityAgent -> ~/.ssh/config"
  printf '\nHost *\n  IdentityAgent "%s"\n' "$OP_AGENT" >> "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
fi

echo
echo "=== NEXT ==="
echo "1. Open 1Password, sign in, then Settings > Developer: enable 'Integrate with 1Password CLI' and 'Use the SSH agent'."
echo "2. Clone the repos (SSH via 1Password):"
echo "   curl -fsSL https://raw.githubusercontent.com/zeshanziya/machine-bootstrap/main/bootstrap-repos.sh | bash"
echo "3. cd ~/Documents/work-area/personal/projects/claude-helpers && ./scripts/new-machine.sh"
