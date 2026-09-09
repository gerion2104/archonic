# Grafischer Login. Nur aktivieren, wenn sddm auch installiert ist --
# so bleibt das Modul harmlos, falls du spaeter auf Autologin umstellst.
if pacman -Qq sddm >/dev/null 2>&1; then
  enable_service sddm.service
  sudo systemctl set-default graphical.target
fi
