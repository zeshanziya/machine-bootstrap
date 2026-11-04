# bootstrap

Step 0 for a fresh machine: install 1Password (where the SSH keys live), point ssh at its agent, then clone the private config repo over SSH. Nothing here needs a token, which is the whole point.

macOS:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/zeshanziya/bootstrap/main/bootstrap-mac.sh)"
```

Fedora:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/zeshanziya/bootstrap/main/bootstrap-fedora.sh)"
```

Then sign in to 1Password, enable Settings > Developer > "Integrate with 1Password CLI" and "Use the SSH agent", and clone:

```bash
curl -fsSL https://raw.githubusercontent.com/zeshanziya/bootstrap/main/bootstrap-repos.sh | bash
```

Everything after that (packages, dotfiles) lives in the private repo these scripts clone. The copies here are mirrors of `scripts/bootstrap-*.sh` there; edit them there and copy over.
