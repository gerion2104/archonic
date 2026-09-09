# Systemdienste aktivieren.
enable_service systemd-timesyncd.service
enable_service ufw.service

once firewall bash -c '
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw --force enable
'
