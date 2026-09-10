# multilib bereitstellt 32-Bit-Bibliotheken -- Steam braucht sie.
# Bei einer minimalen Arch-Installation ist das Repo auskommentiert.
if ! pacman-conf --repo multilib >/dev/null 2>&1; then
  log "multilib aktivieren"
  sudo sed -i '/^#\[multilib\]$/,+1 s/^#//' /etc/pacman.conf
  sudo pacman -Sy
fi
