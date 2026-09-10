#!/usr/bin/env bash
# Gemeinsame Helfer. Wird von install.sh und allen bin/archonic-* gesourced.

ARCHONIC_PATH="${ARCHONIC_PATH:-$HOME/.local/share/archonic}"
ARCHONIC_STATE="$HOME/.local/state/archonic"
ARCHONIC_DONE="$ARCHONIC_STATE/done"
ARCHONIC_MIGRATIONS="$ARCHONIC_STATE/migrations"

mkdir -p "$ARCHONIC_DONE" "$ARCHONIC_MIGRATIONS"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m ! \033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m x \033[0m %s\n' "$*" >&2; exit 1; }

# --- Idempotenz -------------------------------------------------------------
# Jeder Schritt, der nur einmal laufen darf, bekommt einen Marker.
is_done()   { [[ -f "$ARCHONIC_DONE/$1" ]]; }
mark_done() { touch "$ARCHONIC_DONE/$1"; }

# once <name> <befehl...>
once() {
  local name=$1; shift
  if is_done "$name"; then log "skip: $name"; return 0; fi
  "$@"
  mark_done "$name"
}

# --- Module -----------------------------------------------------------------
# Sourcet alle *.sh eines Verzeichnisses in Sortierreihenfolge (10-, 20-, ...).
run_modules() {
  local dir=$1 f
  [[ -d $dir ]] || return 0
  for f in "$dir"/*.sh; do
    [[ -e $f ]] || continue
    log "${f#"$ARCHONIC_PATH"/}"
    # shellcheck disable=SC1090
    source "$f"
  done
}

# --- Pakete -----------------------------------------------------------------
# Paketlisten sind reine Textdateien; # leitet Kommentare ein.
read_packages() {
  local f
  for f in "$@"; do
    [[ -f $f ]] || continue
    sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$f"
  done
}

# Sammelt Pakete, die nicht installiert werden konnten.
ARCHONIC_MISSING=()

# Erst alles auf einmal (schnell). Schlaegt das fehl -- etwa weil ein
# einzelner Name nicht mehr existiert -- Paket fuer Paket nachziehen und
# nur die tatsaechlich fehlenden ueberspringen. Ein toter Paketname darf
# nicht den kompletten Installer anhalten.
pacman_install() {
  local pkgs; mapfile -t pkgs < <(read_packages "$@")
  ((${#pkgs[@]})) || return 0
  if sudo pacman -S --needed --noconfirm -- "${pkgs[@]}"; then return 0; fi
  warn "Sammelinstallation fehlgeschlagen -- versuche einzeln"
  local p
  for p in "${pkgs[@]}"; do
    if ! sudo pacman -S --needed --noconfirm -- "$p" >/dev/null 2>&1; then
      ARCHONIC_MISSING+=("$p"); warn "uebersprungen: $p"
    fi
  done
  return 0
}

aur_install() {
  local pkgs; mapfile -t pkgs < <(read_packages "$@")
  ((${#pkgs[@]})) || return 0
  if ! command -v yay >/dev/null; then
    warn "yay fehlt -- AUR-Pakete uebersprungen"
    ARCHONIC_MISSING+=("${pkgs[@]}"); return 0
  fi
  if yay -S --needed --noconfirm -- "${pkgs[@]}"; then return 0; fi
  warn "AUR-Sammelinstallation fehlgeschlagen -- versuche einzeln"
  local p
  for p in "${pkgs[@]}"; do
    if ! yay -S --needed --noconfirm -- "$p" >/dev/null 2>&1; then
      ARCHONIC_MISSING+=("$p"); warn "uebersprungen: $p"
    fi
  done
  return 0
}

report_missing() {
  ((${#ARCHONIC_MISSING[@]})) || return 0
  warn "Nicht installiert (${#ARCHONIC_MISSING[@]}): ${ARCHONIC_MISSING[*]}"
  warn "Namen in packages/*.packages pruefen -- Paket umbenannt oder entfernt?"
}

# --- Dateien ----------------------------------------------------------------
# Symlink mit Backup: Änderungen an der Config landen direkt im Repo.
link_config() {
  local src=$1 dest=$2
  [[ -e $src ]] || return 0
  mkdir -p "$(dirname "$dest")"
  if [[ -L $dest ]]; then
    [[ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]] && return 0
    rm "$dest"
  elif [[ -e $dest ]]; then
    mv "$dest" "$dest.bak-$(date +%s)"
    warn "Backup angelegt: $dest.bak-*"
  fi
  ln -s "$src" "$dest"
}

# Systemdatei nach /etc schreiben, nur wenn der Inhalt abweicht.
install_etc() {
  local src=$1 dest=$2
  sudo cmp -s "$src" "$dest" 2>/dev/null && return 0
  sudo install -Dm644 "$src" "$dest"
  log "geschrieben: $dest"
}

enable_service()      { sudo systemctl enable --now "$1" || warn "Service $1 nicht aktivierbar"; }
enable_user_service() { systemctl --user enable --now "$1" || warn "User-Service $1 nicht aktivierbar"; }
