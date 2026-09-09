# archonic

Mein Arch-Setup als Code. Ein Repo, ein Script, reproduzierbar auf jedem Rechner.

## Neue Maschine aufsetzen

1. Arch normal installieren (`archinstall`, minimal, kein Desktop).
2. Anmelden und ausführen:

```
bash <(curl -sL https://raw.githubusercontent.com/gerion2104/archonic/main/boot.sh)
```

## Aufbau

```
archonic/
├── boot.sh              Bootstrap: git installieren, Repo klonen, install.sh starten
├── install.sh           Orchestrator -- sourcet der Reihe nach alle Module
├── lib/common.sh        Helfer: log, once, link_config, pacman_install, ...
├── packages/*.packages  Paketlisten als reiner Text
├── install/
│   ├── preflight/       Mirrors, AUR-Helper, Vorbedingungen
│   ├── packages/        Installiert die Paketlisten
│   ├── config/          System: /etc, Dienste, Firewall, Hardware
│   └── user/            $HOME: Configs verlinken, Shell, XDG
├── config/              Dotfiles -> werden nach ~/.config verlinkt
├── etc/                 Wird 1:1 nach /etc gespiegelt
├── bin/archonic*          Eigene Kommandos, landen in ~/.local/bin
└── migrations/          <unix-timestamp>.sh -- einmalige Fixes für Bestandssysteme
```

## Die drei Regeln

1. **Alles ist idempotent.** `install.sh` darf jederzeit erneut laufen.
   Schritte, die nur einmal dürfen, in `once <name> <befehl>` wickeln.
2. **Neue Rechner bekommen den Zustand über `config/` und `packages/`.**
   Bestandsrechner bekommen ihn über eine Migration. Beides pflegen.
3. **Maschinenspezifisches wird erkannt, nicht konfiguriert.**
   Siehe `install/config/30-hardware.sh` -- DMI-Vendor, CPU, Akku abfragen
   statt Varianten von Hand zu pflegen.

## Alltag

```
archonic update      # Repo + System aktualisieren, Migrationen ausführen
archonic refresh     # Configs neu verlinken
archonic install     # Installer erneut laufen lassen
archonic-new-migration
```

## Warum Symlinks statt Kopien

`config/` wird nach `~/.config` **verlinkt**. Änderst du deine Hyprland-Config,
änderst du direkt das Repo -- `git diff` zeigt sie, `git push` sichert sie.
Omarchy kopiert stattdessen aus `/etc/skel`, weil es an fremde Nutzer ausliefert
und deren Änderungen nicht überschreiben will. Für ein persönliches Setup ist
der Symlink der bessere Trade-off.
