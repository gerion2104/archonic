# Shell-Umgebung. archonic/bin auf den PATH holen.
mkdir -p "$HOME/.local/bin"
for f in "$ARCHONIC_PATH"/bin/*; do
  [[ -f $f && -x $f ]] || continue
  ln -sf "$f" "$HOME/.local/bin/$(basename "$f")"
done
