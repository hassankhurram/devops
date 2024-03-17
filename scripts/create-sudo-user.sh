#!/bin/bash

# Main script
read -p "Enter the username to create: " username_input
if [ -z "$username_input" ]; then
    echo "Username cannot be empty." >&2
    exit 1
fi

# Create the user
sudo adduser "$username_input"

# Add the user to the sudo group
sudo usermod -aG sudo "$username_input"

su - $username_input
#sudo -u "$username_input" sh -c "$(curl -fsSL https://raw.githubusercontent.com/hassankhurram/devops/main/scripts/ubuntu-minimal.sh)"

#sudo reboot now