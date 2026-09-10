# boot.sh klont ueber HTTPS (public Repo, kein Schluessel noetig).
# Pushen braucht SSH -- deshalb hier einmalig umstellen, statt es auf
# jeder neuen Maschine von Hand zu tippen.
if command -v git >/dev/null && [[ -d "$ARCHONIC_PATH/.git" ]]; then
  _url=$(git -C "$ARCHONIC_PATH" remote get-url origin 2>/dev/null || true)
  if [[ $_url == https://github.com/* ]]; then
    _ssh=${_url/https:\/\/github.com\//git@github.com:}
    git -C "$ARCHONIC_PATH" remote set-url origin "$_ssh"
    log "Remote auf SSH umgestellt: $_ssh"
  fi
  unset _url _ssh
fi
