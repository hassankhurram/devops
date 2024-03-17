#!/bin/bash

# Function to check if a user exists
user_exists() {
    id "$1" &>/dev/null
}

# Function to create a user
create_user() {
    username="$1"
    if ! user_exists "$username"; then
        sudo useradd -m "$username"
        echo "User '$username' created successfully."
    else
        echo "User '$username' already exists."
    fi
}

# Function to add a user to the sudo group
add_to_sudo_group() {
    username="$1"
    if user_exists "$username"; then
        sudo usermod -aG sudo "$username"
        echo "User '$username' added to the sudo group."
    else
        echo "User '$username' does not exist."
    fi
}

# Function to switch to a user
switch_user() {
    username="$1"
    if user_exists "$username"; then
        su - "$username"
    else
        echo "User '$username' does not exist."
    fi
}

# Main script
read -p "Enter the username to create: " username
create_user "$username"
add_to_sudo_group "$username"
switch_user "$username"
