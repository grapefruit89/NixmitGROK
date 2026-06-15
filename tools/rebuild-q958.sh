#!/usr/bin/env bash
# Sync /home/nixos → /etc/nixos und nixos-rebuild switch (braucht root).
set -euo pipefail

SRC=/home/nixos
DST=/etc/nixos

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Bitte mit sudo ausführen: sudo $0"
  exit 1
fi

echo "==> Sync $SRC → $DST (ohne .git, secrets, lokale Artefakte)"
rsync -a --delete \
  --exclude '.git/' \
  --exclude '.nix-defexpr/' \
  --exclude '**/profile.local.nix' \
  --exclude 'secrets.sops.yaml' \
  "$SRC/" "$DST/"

# profile.local.nix bleibt auf dem Host (gitignored)
if [[ -f "$SRC/machines/q958/profile.local.nix" ]]; then
  install -m 600 "$SRC/machines/q958/profile.local.nix" "$DST/machines/q958/profile.local.nix"
fi

echo "==> nixos-rebuild switch --flake $DST#q958"
nixos-rebuild switch --flake "$DST#q958" --impure

echo "==> Fertig. Rollout: $(grep 'stufe =' "$DST/machines/q958/profile.nix" | head -1)"