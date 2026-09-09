# Hardwarespezifisches -- läuft nur auf der passenden Maschine.
vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo unknown)
cpu=$(grep -m1 vendor_id /proc/cpuinfo | awk '{print $3}')

case "$cpu" in
  GenuineIntel) sudo pacman -S --needed --noconfirm intel-ucode ;;
  AuthenticAMD) sudo pacman -S --needed --noconfirm amd-ucode ;;
esac

# Beispiel: laptopspezifische Quirks. Zieh dir hier rein, was nur auf
# einzelnen Maschinen gilt -- so bleibt ein Script für alle Rechner nutzbar.
case "$vendor" in
  *Framework*) log "Framework erkannt" ;;
  *LENOVO*)    log "Lenovo erkannt"    ;;
  *)           : ;;
esac

# Akku vorhanden -> Energieverwaltung
if [[ -d /sys/class/power_supply/BAT0 ]]; then
  sudo pacman -S --needed --noconfirm power-profiles-daemon
  enable_service power-profiles-daemon.service
fi
