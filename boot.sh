#!/usr/bin/env bash
# Einstiegspunkt auf einem frisch installierten Arch:
#   bash <(curl -sL https://raw.githubusercontent.com/gerion2104/archonic/main/boot.sh)
set -euo pipefail

REPO="${ARCHONIC_REPO:-https://github.com/gerion2104/archonic.git}"
REF="${ARCHONIC_REF:-main}"
DEST="${ARCHONIC_PATH:-$HOME/.local/share/archonic}"

command -v pacman >/dev/null || { echo "Kein Arch-System."; exit 1; }
[[ $EUID -ne 0 ]] || { echo "Nicht als root starten."; exit 1; }

sudo pacman -Sy --needed --noconfirm git

if [[ -d $DEST/.git ]]; then
  git -C "$DEST" fetch origin "$REF"
  git -C "$DEST" reset --hard "origin/$REF"
else
  mkdir -p "$(dirname "$DEST")"
  git clone --branch "$REF" "$REPO" "$DEST"
fi

exec "$DEST/install.sh"
