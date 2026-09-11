# SilentSDDM auf eigenes Wallpaper setzen.
#
# Hinweis: Der "background"-Eintrag in den Preset-Configs wird vom Theme
# nicht ausgewertet -- es laedt immer backgrounds/default.jpg. Deshalb
# ueberschreiben wir diese Datei direkt, statt die Config zu patchen.
# Getestet mit sddm-silent-theme 1.5.0.
#
# Alles unter /usr/share/ gehoert dem Paket; ein Update setzt es zurueck.
# Darum bei jedem install.sh-Lauf neu anwenden.
SDDM_THEME=/usr/share/sddm/themes/silent
WALL="$ARCHONIC_PATH/wallpapers/current.jpg"

if [[ -d $SDDM_THEME ]]; then
  sudo sed -i 's|^ConfigFile=.*|ConfigFile=configs/catppuccin-mocha.conf|' \
    "$SDDM_THEME/metadata.desktop"

  if [[ -f $WALL ]]; then
    # Original einmalig sichern, damit man zurueck kann
    if [[ ! -f "$SDDM_THEME/backgrounds/default.jpg.orig" ]]; then
      sudo cp "$SDDM_THEME/backgrounds/default.jpg" \
              "$SDDM_THEME/backgrounds/default.jpg.orig"
    fi
    sudo install -Dm644 "$WALL" "$SDDM_THEME/backgrounds/default.jpg"

    # Ohne das gewinnt background-color gegen das Bild und man sieht
    # nur eine einfarbige Flaeche.
    sudo sed -i 's/^use-background-color\s*=\s*true/use-background-color = false/' \
      "$SDDM_THEME/configs/catppuccin-mocha.conf"

  else
    warn "wallpapers/current.jpg fehlt -- SDDM behaelt sein Standardbild"
  fi
fi
