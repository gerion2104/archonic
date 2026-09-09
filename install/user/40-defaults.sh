# Standardanwendungen -- braucht laufendes XDG, daher hier statt in /etc.
once xdg-defaults bash -c '
  xdg-mime default org.gnome.Nautilus.desktop inode/directory 2>/dev/null || true
'
