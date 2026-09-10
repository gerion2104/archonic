# Gruppenmitgliedschaften. Wirken erst nach einer Neuanmeldung.
# vboxusers: USB-Geraete in VirtualBox. docker: docker ohne sudo.
for _grp in vboxusers docker; do
  if getent group "$_grp" >/dev/null 2>&1; then
    if ! id -nG "$USER" | tr ' ' '\n' | grep -qx "$_grp"; then
      sudo usermod -aG "$_grp" "$USER"
      log "Benutzer zu Gruppe $_grp hinzugefuegt -- Neuanmeldung noetig"
    fi
  fi
done
unset _grp
