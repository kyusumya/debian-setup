sudo apt install -y unattended-upgrades ufw flatpak fcitx5-mozc git rsync

sudo dpkg-reconfigure --priority=low unattended-upgrades
grep -q 'APT::Periodic::Download-Upgradeable-Packages' /etc/apt/apt.conf.d/10periodic || \
echo 'APT::Periodic::Download-Upgradeable-Packages "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
grep -q 'APT::Periodic::AutocleanInterval' /etc/apt/apt.conf.d/10periodic || \
echo 'APT::Periodic::AutocleanInterval "7";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
sudo sed -i 's|^\(\s*\)//\s*\("origin=Debian,codename=${distro_codename}-updates";\)|\1\2|' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's|^\(\s*\)//\s*\("origin=Debian,codename=${distro_codename}-proposed-updates";\)|\1\2|' /etc/apt/apt.conf.d/50unattended-upgrades

sudo ufw --force enable && sudo ufw default deny incoming

flatpak install -y flathub one.ablaze.floorp com.vscodium.codium

sed -i "s/^#alias \(ll\|la\|l\)=/alias \1=/" ~/.bashrc

DOTFILES_DIR=~/.cache/dotfiles
if [ ! -d "$DOTFILES_DIR" ]; then
  git clone https://github.com/kyusumya/dotfiles "$DOTFILES_DIR"
  rsync -av --exclude='.*' "$DOTFILES_DIR/" ~/.config/
  rm -rf "$DOTFILES_DIR"
fi
