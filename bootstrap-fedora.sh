#!/usr/bin/env bash
# Step 0 for a virgin Fedora machine (Linux sibling of bootstrap-mac.sh). Needs NO clone:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/zeshanziya/bootstrap/main/bootstrap-fedora.sh)"
#
# Adds the 1Password rpm repo, installs 1Password + its CLI + git, and points
# ssh at the 1Password SSH agent so bootstrap-repos.sh can clone over SSH.
# Idempotent.
#
# Then: sign in to 1Password, enable Settings > Developer > "Integrate with
# 1Password CLI" + "Use the SSH agent", and run scripts/bootstrap-repos.sh.
set -euo pipefail

REPO_FILE=/etc/yum.repos.d/1password.repo
if [ -f "$REPO_FILE" ]; then
  echo "OK:   1Password rpm repo already configured"
else
  echo "ADD:  1Password rpm repo -> $REPO_FILE"
  sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
  printf '[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://downloads.1password.com/linux/keys/1password.asc\n' | sudo tee "$REPO_FILE" >/dev/null
fi

for pkg in 1password 1password-cli git; do
  if rpm -q "$pkg" >/dev/null 2>&1; then
    echo "OK:   $pkg"
  else
    echo "INST: $pkg"
    sudo dnf install -y "$pkg"
  fi
done

# Point ssh at the 1Password SSH agent (the app-side toggle still has to be
# enabled by hand: Settings > Developer > "Use the SSH agent").
SSH_CONFIG="$HOME/.ssh/config"
# shellcheck disable=SC2088  # ssh expands ~ in IdentityAgent itself; keep it literal in the config
OP_AGENT='~/.1password/agent.sock'
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
if grep -qs '.1password/agent.sock' "$SSH_CONFIG"; then
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
echo "   curl -fsSL https://raw.githubusercontent.com/zeshanziya/bootstrap/main/bootstrap-repos.sh | bash"
echo "3. cd ~/Documents/work-area/personal/projects/claude-helpers && ./scripts/new-machine-fedora.sh"
