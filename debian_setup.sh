#!/bin/bash
set -e

sudo apt update && sudo apt dist-upgrade -y && sudo apt install -y unattended-upgrades ufw flatpak fcitx5-mozc git rsync

sudo dpkg-reconfigure --priority=low unattended-upgrades
grep -q 'APT::Periodic::Download-Upgradeable-Packages' /etc/apt/apt.conf.d/10periodic || \
echo 'APT::Periodic::Download-Upgradeable-Packages "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
grep -q 'APT::Periodic::AutocleanInterval' /etc/apt/apt.conf.d/10periodic || \
echo 'APT::Periodic::AutocleanInterval "7";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
sudo sed -i 's|^\([[:space:]]*\)//[[:space:]]*\("origin=Debian,codename=${distro_codename}-updates";\)|\1\2|' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's|^\([[:space:]]*\)//[[:space:]]*\("origin=Debian,codename=${distro_codename}-proposed-updates";\)|\1\2|' /etc/apt/apt.conf.d/50unattended-upgrades

sudo ufw --force enable && sudo ufw default deny incoming

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub one.ablaze.floorp com.vscodium.codium

sed -i -E 's/^[[:space:]]*#(alias (ll|la|l)=)/\1/' $HOME/bashrc

DOTFILES_DIR=$HOME/.cache/dotfiles
if [ ! -d "$DOTFILES_DIR" ]; then
  git clone https://github.com/kyusumya/dotfiles "$DOTFILES_DIR"
  pkill xfce4-panel && pkill xfwm4 && pkill xfsettingsd
  rm -rf "$HOME/.config/xfce4"
  rsync -av --exclude='.git/' "$DOTFILES_DIR/" $HOME/.config/
  chown -R $USER:$USER "$HOME/.config/"
  chmod -R u+rw "$HOME/.config/"
  rm -rf "$DOTFILES_DIR"
  xfce4-panel &
  xfwm4 --replace &
  xfsettingsd --replace &
fi

sudo reboot
