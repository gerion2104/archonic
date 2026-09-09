# Grundannahmen prüfen, bevor irgendetwas installiert wird.
ping -c1 -W3 archlinux.org >/dev/null 2>&1 || die "Keine Netzwerkverbindung."
[[ -d /sys/firmware/efi ]] || warn "Kein UEFI erkannt -- Bootloader-Teil ggf. anpassen."
