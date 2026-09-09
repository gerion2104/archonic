# config/<name>  ->  ~/.config/<name>  als Symlink.
# Symlink statt Kopie: Änderungen sind sofort im Repo und damit in git.
for dir in "$ARCHONIC_PATH"/config/*/; do
  [[ -d $dir ]] || continue
  name=$(basename "$dir")
  link_config "$dir" "$HOME/.config/$name"
done

# Einzeldateien im Home
link_config "$ARCHONIC_PATH/config/bashrc"   "$HOME/.bashrc"
link_config "$ARCHONIC_PATH/config/gitconfig" "$HOME/.gitconfig"
