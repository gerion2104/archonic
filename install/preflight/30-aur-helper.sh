# yay bauen, falls nicht vorhanden.
if ! command -v yay >/dev/null; then
  log "yay bauen"
  tmp=$(mktemp -d)
  git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi
