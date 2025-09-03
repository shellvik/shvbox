#!/bin/bash

set -e  # Exit script on any error
SCRIPT_DIR=$(dirname "$(realpath "$0")")

sudo apt update -y

# Install essentials
install_essentials() {
  GREEN="\e[32m"
  RED="\e[31m"
  YELLOW="\e[33m"
  CYAN="\e[36m"
  RESET="\e[0m"

  local packages=(
    kitty
    terminator
    mate-tweak
    mate-desktop-environment
    dconf-editor
    synapse
    unzip
    stow
  )

  echo -e "\n${CYAN}➜ Updating package lists...${RESET}"
  sudo apt update -y >/dev/null 2>&1 && \
    echo -e "${GREEN}✔ Package lists updated${RESET}" || \
    echo -e "${RED}✘ Failed to update package lists${RESET}"

  echo -e "\n${CYAN}➜ Installing essentials...${RESET}"

  for pkg in "${packages[@]}"; do
    if dpkg -s "$pkg" &>/dev/null; then
      echo -e "${YELLOW}⚡ $pkg is already installed${RESET}"
    else
      if sudo apt install -y "$pkg" >/dev/null 2>&1; then
        echo -e "${GREEN}✔ Installed $pkg${RESET}"
      else
        echo -e "${RED}✘ Failed to install $pkg${RESET}"
      fi
    fi
  done

  echo -e "\n${CYAN}➜ Essentials setup complete.${RESET}\n"
}



read -p "Install Mate Desktop essentials? [Y/n] " mate
if [[ $mate =~ ^[Yy]$ ]]; then
  install_essentials
else
  echo "Installation cancelled."
fi


rice() {
  # VPN config
  chmod +x "$SCRIPT_DIR/src/htb-vpn-config/"*.sh
  sudo cp -R "$SCRIPT_DIR/src/htb-vpn-config/" /etc/htb-vpn-config
  sudo cp "$SCRIPT_DIR/src/htb-vpn-config/default.conf" /etc/openvpn/config.conf
  sudo ln -sf /etc/htb-vpn-config/shvpn.sh /usr/bin/shvpn

  
  # Bash config
  [ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc_bak"
  sudo cp "$SCRIPT_DIR/src/bashrc" "$HOME/.bashrc"

  # Themes and Icons
  [ -f "$SCRIPT_DIR/src/Material-Black-Lime-Numix-FLAT.zip" ] && \
    sudo unzip -o "$SCRIPT_DIR/src/Material-Black-Lime-Numix-FLAT.zip" -d "$SCRIPT_DIR/src/" && \
    sudo cp -R "$SCRIPT_DIR/src/Material-Black-Lime-Numix-FLAT" /usr/share/icons/

  [ -f "$SCRIPT_DIR/src/themes.zip" ] && \
    sudo unzip -o "$SCRIPT_DIR/src/themes.zip" -d "$SCRIPT_DIR/src/" && \
    sudo cp -R "$SCRIPT_DIR/src/themes" /usr/share/
    echo "Copying themes... to /usr/share/themes"

  # Wallpaper
  [ -d "$SCRIPT_DIR/src/wallpaper" ] && \
    sudo cp -R "$SCRIPT_DIR/src/wallpaper/" /usr/share/backgrounds/

  # Fonts
  [ -d "$SCRIPT_DIR/src/fonts" ] && \
    sudo mkdir -p "$HOME/.local/share/fonts" && \
    sudo unzip -o "$SCRIPT_DIR/src/fonts/*.zip" -d "$SCRIPT_DIR/src/fonts/" && \
    sudo cp -R "$SCRIPT_DIR/src/fonts/" "$HOME/.local/share/"
}


read -p "Run setup script? [Y/n] " setup
if [[ $setup =~ ^[Yy]$ ]]; then
  rice
else
  echo "Rice setup cancelled."
fi

fix_locale() {
  if ! locale | grep -q ".UTF-8"; then
    echo "Fixing locale to UTF-8..."
    echo 'LANG="en_US.UTF-8"' | sudo tee /etc/default/locale
    echo 'LC_ALL="en_US.UTF-8"' | sudo tee -a /etc/default/locale
    sudo locale-gen en_US.UTF-8
    sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
  else
    echo "Locale is already set to UTF-8."
  fi
}

install_editor() {
  echo "Installing Obsidian and Sublime..."
  read -p "Go to: https://obsidian.md/download and paste the debian download link here: " debdown
  wget -q $debdown -O /tmp/obsidian.deb
  sudo dpkg -i /tmp/obsidian.deb && rm -f /tmp/obsidian.deb

  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | \
    gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg >/dev/null
  echo "deb https://download.sublimetext.com/ apt/stable/" | \
    sudo tee /etc/apt/sources.list.d/sublime-text.list
  sudo apt update
  sudo apt install -y sublime-text
}

read -p "Install editors? [Y/n] " ess
if [[ $ess =~ ^[Yy]$ ]]; then
  install_editor
else
  echo "Installation cancelled."
fi

