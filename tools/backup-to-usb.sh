#!/usr/bin/env bash
# Vollbackup: Git-Repo + gitignored Secrets → USB /NixmitGrok_USB
set -euo pipefail

SRC=/home/nixos
USB_MOUNT="${USB_MOUNT:-/mnt/usbinspect}"
DEST="${USB_MOUNT}/NixmitGrok_USB"
STAMP=$(date -u +%Y%m%dT%H%M%SZ)

if [[ "$(id -u)" -ne 0 ]]; then
  exec sudo "$SRC/tools/backup-to-usb.sh" "$@"
fi

if ! mountpoint -q "$USB_MOUNT"; then
  echo "FEHLER: USB nicht gemountet unter $USB_MOUNT"
  exit 1
fi

echo "==> USB rw remount"
mount -o remount,rw "$USB_MOUNT" 2>/dev/null || mount -o remount,rw /dev/sdb1 "$USB_MOUNT"

mkdir -p "$DEST"

echo "==> Git bundle → $DEST/repo-${STAMP}.bundle"
git -C "$SRC" bundle create "$DEST/repo-${STAMP}.bundle" --all

echo "==> Git-Archiv (ohne .git) → $DEST/nixos-tree-${STAMP}.tar.zst"
tar -C "$SRC" \
  --exclude='.git' \
  --exclude='.cache' \
  --exclude='.grok' \
  --exclude='result' \
  --exclude='result-*' \
  -cf - . | zstd -19 -T0 -o "$DEST/nixos-tree-${STAMP}.tar.zst"

echo "==> Lokale Secrets (gitignored)"
SECRETS_ARCHIVE="$DEST/local-secrets-${STAMP}.tar.zst"
tar -C "$SRC" -cf - \
  machines/q958/profile.local.nix \
  2>/dev/null | zstd -19 -T0 -o "$SECRETS_ARCHIVE" || true

if [[ -d /var/lib/secrets ]]; then
  tar -C /var/lib -cf - secrets 2>/dev/null | zstd -19 -T0 -o "$DEST/var-lib-secrets-${STAMP}.tar.zst" || true
fi

if [[ -f /home/nixos/.ssh/id_ed25519_github ]]; then
  install -d -m 700 "$DEST/ssh"
  install -m 600 /home/nixos/.ssh/id_ed25519_github "$DEST/ssh/id_ed25519_github"
  [[ -f /home/nixos/.ssh/id_ed25519_github.pub ]] && \
    install -m 644 /home/nixos/.ssh/id_ed25519_github.pub "$DEST/ssh/id_ed25519_github.pub"
fi

cat > "$DEST/README-${STAMP}.txt" <<EOF
NixmitGrok_USB Backup — ${STAMP}
Host: $(hostname)
Git: 2634f70 (main)
Inhalt:
  - repo-*.bundle     → git clone / git pull aus Bundle
  - nixos-tree-*.tar.zst → Arbeitsbaum ohne .git
  - local-secrets-*.tar.zst → profile.local.nix (NIEMALS nach GitHub)
  - var-lib-secrets-*.tar.zst → /var/lib/secrets Runtime
  - ssh/ → Deploy-Key GitHub (falls vorhanden)
Restore profile.local:
  tar -I zstd -xf local-secrets-*.tar.zst -C /home/nixos
EOF

sync
echo "==> Fertig: $DEST"
ls -lh "$DEST"