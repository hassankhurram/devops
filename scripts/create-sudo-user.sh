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

read -p "STEP 4: Do you want to add current user '${username_input}' to visudo? (y/n):" answer
if [ "$answer" = "y" ]; then
        echo "Adding $username_input to sudoers file..."
        echo "$username_input ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers > /dev/null
        echo "User $username_input added to sudoers file."
fi

echo "User '$username_input' created and added to the sudo group successfully."




su - $username_input
