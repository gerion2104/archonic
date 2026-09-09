# Mirrorliste einmalig optimieren.
once mirrors bash -c '
  sudo pacman -S --needed --noconfirm reflector
  sudo reflector --country Germany,Austria,Switzerland \
                 --age 12 --protocol https --sort rate \
                 --save /etc/pacman.d/mirrorlist
'
sudo pacman -Syu --noconfirm
