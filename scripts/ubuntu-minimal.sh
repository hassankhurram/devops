#!/bin/bash

# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or distribute
# this software, either in source code form or as a compiled binary, for any
# purpose, commercial or non-commercial, and by any means.
#
# In jurisdictions that recognize copyright laws, the author or authors of
# this software dedicate any and all copyright interest in the software to
# the public domain. We make this dedication for the benefit of the public
# at large and to the detriment of our heirs and successors. We intend this
# dedication to be an overt act of relinquishment in perpetuity of all
# present and future rights to this software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org>
#
# Author: Hassan Khurram
# GitHub: https://github.com/hassankhurram
# Website: https://hassankhurram.com


# Reference: https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# ------------------------------------------------------------
# Make sure important variables exist if not already defined
# ----------------- ENVIRONMENT VARIABLES block -----------------------
set -e
VERSION=0.1

# Set USER if not exists / can be undefined in containers.
USER=${USER:-$(id -u -n)}
# Set HOME Var, may cause an issue if not defined.
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
HOME="${HOME:-$(eval echo ~$USER)}"

# ----------------- ENVIRONMENT VARIABLES block end -----------------------
# ----------------- functions block -----------------------
command_exists() {
  command -v "$@" >/dev/null 2>&1
}

user_can_sudo() {
    command_exists sudo || return 1
       # Termux can't run sudo, so we can detect it and exit the function early.
        case "$PREFIX" in
        *com.termux*) return 1 ;;
        esac
    ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

nvm_profile_is_bash_or_zsh() {
  local TEST_PROFILE
  TEST_PROFILE="${1-}"
  case "${TEST_PROFILE-}" in
    *"/.bashrc" | *"/.bash_profile" | *"/.zshrc" | *"/.zprofile")
      return
    ;;
    *)
      return 1
    ;;
  esac
}


# The [ -t 1 ] check only works when the function is not called from
# a subshell (like in `$(...)` or `(...)`, so this hack redefines the
# function at the top level to always return false when stdout is not
# a tty.
if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi


# ----------------- functions block end -------------------
# ----------------- script block ------------------- 
# lets check if user can sudo



echo "Welcome to server ubuntu minimal server essentials v${VERSION}"

if [ "$(command -v sudo)" != "/usr/bin/sudo" ]; then
    echo "sudo is not installed. Installing sudo..."
    # Update package lists and install sudo
    sudo apt update
    sudo apt install sudo -y
fi


if ! user_can_sudo; then
    echo "You should be able to do sudo, please set yourself to sudo." && exit 1;
fi
echo "Updating pre-requisites...";
# sudo apt update -y
# sudo apt upgrade -y

read -p "STEP 1: Do you want to update the current user: \"$USER\" password? (y/n):" answer
if [ "$answer" = "y" ]; then
        sudo passwd $USER
fi

read -p "STEP 2: Do you want to update the root password? (y/n):" answer
if [ "$answer" = "y" ]; then
        sudo passwd root
fi


echo "STEP 3: Installing essential packages";
sudo usermod -aG sudo $USER
sudo apt install git
sudo apt install curl wget -y
sudo apt install nano
sudo apt install vim
sudo apt install net-tools htop -y


read -p "STEP 4: Do you want to add current user '${USER}' to visudo? (y/n):" answer
if [ "$answer" = "y" ]; then
        echo "Adding $USER to sudoers file..."
        echo "$USER ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers > /dev/null
        echo "User $USER added to sudoers file."
fi

# Check if Oh My Zsh is already installed
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed."
else
    # Prompt the user to change the shell to Zsh
    read -p "Do you want to change the shell to Zsh/Oh My Zsh? (y/n): " answer
    if [ "$answer" = "y" ]; then
        # Install Zsh and Oh My Zsh
        sudo apt install zsh -y
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
fi

read -p "STEP 6: Do you want to install Tailscale? (y/n):" answer
if [ "$answer" = "y" ]; then
      curl -fsSL https://tailscale.com/install.sh | sh
      sudo tailscale up
fi

read -p "STEP 7: Do you want to install nvm? (y/n):" answer
if [ "$answer" = "y" ]; then
       curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

read -p "STEP 8: Do you want to install docker? (y/n):" answer
if [ "$answer" = "y" ]; then
      # Add Docker's official GPG key:
        sudo apt-get update
        sudo apt-get install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        sudo usermod -aG docker $USER
fi

read -p "STEP 9: Do you want to install google cloud sdk? (y/n):" answer
if [ "$answer" = "y" ]; then
      curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-468.0.0-linux-x86_64.tar.gz
      tar -xf google-cloud-cli-468.0.0-linux-x86_64.tar.gz
      sudo chmod +x ./google-cloud-sdk/install.sh
      ./google-cloud-sdk/install.sh
      ./google-cloud-sdk/bin/gcloud init
      rm -rf ./google-cloud-sdk google-cloud-cli-468.0.0-linux-x86_64.tar.gz
      gcloud init
fi


read -p "STEP 10: Do you want to add your public key to authorized_keys? (y/n): " answer
if [ "$answer" = "y" ]; then
    # Prompt the user for their public key
    echo "Please create the key using the following command:"
    echo
    echo "mkdir -p ~/.ssh && ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/$(hostname); echo; echo \"copy the key below:\"; echo; cat ~/.ssh/$(hostname).pub; echo;"
    echo
    read -p "Enter your public key: " public_key
    if [ -n "$public_key" ]; then
        # Ensure the .ssh directory exists
        mkdir -p "$HOME/.ssh"

        # Check if authorized_keys file exists
        if [ ! -f "$HOME/.ssh/authorized_keys" ]; then
            touch "$HOME/.ssh/authorized_keys"
            chmod 600 "$HOME/.ssh/authorized_keys"
        fi
        
        # Append the public key to the authorized_keys file
        echo "$public_key" >> "$HOME/.ssh/authorized_keys"
        echo "Public key added to authorized_keys."
    else
        echo "No public key provided. Skipping."
    fi
else
    echo "Skipping adding public key to authorized_keys."
fi

echo "ssh using this command now";
echo "ssh -i ~/.ssh/$(hostname) $USER@$(sudo tailscale ip --4)"
echo "all things done... rebooting in 5 seconds";
sleep 5;
sudo reboot now;


# ----------------- script block end ------------------- 