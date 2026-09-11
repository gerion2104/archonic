# Systemdienste aktivieren.
enable_service systemd-timesyncd.service
enable_service ufw.service

once firewall bash -c '
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw limit ssh
  sudo ufw --force enable
'

# Netzwerk und Bluetooth. Ohne aktiven Dienst laufen nmtui und
# bluetoothctl ins Leere, und die Waybar-Module zeigen nichts.
enable_service NetworkManager.service
pacman -Qq bluez >/dev/null 2>&1 && enable_service bluetooth.service
