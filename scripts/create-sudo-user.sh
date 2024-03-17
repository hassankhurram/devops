#!/bin/bash

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

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


echo "User '$username_input' created and added to the sudo group successfully."

su - $username_input
