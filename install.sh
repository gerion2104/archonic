#!/usr/bin/env bash
# Hauptinstaller. Idempotent -- darf beliebig oft laufen.
set -euo pipefail

ARCHONIC_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ARCHONIC_PATH
# shellcheck source=lib/common.sh
source "$ARCHONIC_PATH/lib/common.sh"

[[ $EUID -ne 0 ]] || die "Nicht als root ausführen -- sudo wird gezielt aufgerufen."
command -v pacman >/dev/null || die "Kein Arch-System."

FRESH=0
is_done install-complete || FRESH=1

log "Sudo-Zugriff anfordern"
sudo -v
# Sudo-Timestamp am Leben halten, solange der Installer läuft
while sudo -n true 2>/dev/null; do sleep 50; kill -0 "$$" 2>/dev/null || exit; done &
SUDO_KEEPALIVE=$!
trap 'kill $SUDO_KEEPALIVE 2>/dev/null || true' EXIT

run_modules "$ARCHONIC_PATH/install/preflight"   # Mirrors, AUR-Helper, Grundlagen
run_modules "$ARCHONIC_PATH/install/packages"    # Paketlisten
run_modules "$ARCHONIC_PATH/install/config"      # System: /etc, Services, Firewall
run_modules "$ARCHONIC_PATH/install/user"        # $HOME: Configs, Shell, Tools

if ((FRESH)); then
  log "Frische Installation -- alle Migrationen als erledigt markieren"
  "$ARCHONIC_PATH/bin/archonic-migrate" --mark-all
  mark_done install-complete
else
  "$ARCHONIC_PATH/bin/archonic-migrate"
fi

log "Fertig. Neu anmelden oder neu starten."
