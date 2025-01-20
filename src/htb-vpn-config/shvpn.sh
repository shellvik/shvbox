#!/bin/bash

# Instructions --> Keep the lab and academy OpenVPN configs in /etc/htb-vpn-config as lab-htb.ovpn and aca-htb.ovpn

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'
TICK='\033[0;32m\u2713'

VPN_CONFIG_DIR="/etc/htb-vpn-config"
SYM_LINK_PATH="/etc/openvpn/config.conf"
DEFAULT_CONF="$VPN_CONFIG_DIR/default.conf"

switch_vpn_config() {
  local config_file=$1
  if [[ -f "$VPN_CONFIG_DIR/$config_file" ]]; then
    sudo ln -sf "$VPN_CONFIG_DIR/$config_file" "$SYM_LINK_PATH"
    echo -e "${GREEN}${TICK} Switched to $config_file${RESET}"
  else
    echo -e "${RED}Error: $config_file does not exist!${RESET}"
    exit 1
  fi
}

# Function to clean up and restore the default configuration
cleanup() {
  sudo ln -sf "$DEFAULT_CONF" "$SYM_LINK_PATH"
  echo -e "${GREEN}${TICK} Reverted to default.conf${RESET}"
}

# Set up the cleanup trap for script termination (Ctrl+C or normal exit)
trap cleanup EXIT

if [ $# -eq 0 ]; then
  sudo ln -sf "$DEFAULT_CONF" "$SYM_LINK_PATH"
  echo -e "${GREEN}${TICK} No VPN config provided, defaulting to default.conf${RESET}"
  sudo openvpn --config "$SYM_LINK_PATH" 
elif [ "$1" == "lab" ]; then
  switch_vpn_config "lab-htb.ovpn"
  sudo openvpn --config "$SYM_LINK_PATH" 
elif [ "$1" == "aca" ]; then
  switch_vpn_config "aca-htb.ovpn"
  sudo openvpn --config "$SYM_LINK_PATH" 
else
  echo -e "${RED}Usage: shvpn {lab|aca}${RESET}"
  exit 1
fi
