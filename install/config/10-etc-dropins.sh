# Eigene /etc-Dateien aus dem Repo ausrollen.
# Alles unter etc/ wird 1:1 nach /etc gespiegelt.
if [[ -d "$ARCHONIC_PATH/etc" ]]; then
  while IFS= read -r -d '' src; do
    rel=${src#"$ARCHONIC_PATH"/etc/}
    install_etc "$src" "/etc/$rel"
  done < <(find "$ARCHONIC_PATH/etc" -type f -print0)
fi
