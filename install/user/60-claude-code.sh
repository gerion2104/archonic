# Claude Code ist kein Paket, sondern ein eigenstaendiges Binary.
# Der offizielle Installer legt es unter ~/.local/bin/claude ab und
# braucht kein Node.js. Danach aktualisiert es sich selbst.
if ! command -v claude >/dev/null; then
  once claude-code bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
fi
