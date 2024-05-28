#!/bin/sh

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

# Function to prompt the user for confirmation
prompt_user() {
    read -p "$1 (y/n): " answer
    if [ "$answer" != "y" ]; then
        return 1
    fi
    return 0
}

# Prompt the user for the LXC container ID
read -p "Please enter the LXC container ID: " CONTAINER_ID

LXC_CONFIG_FILE="/etc/pve/lxc/${CONTAINER_ID}.conf"

# Check if the LXC configuration file exists
if [ ! -f "$LXC_CONFIG_FILE" ]; then
  echo "Error: LXC configuration file for container ID $CONTAINER_ID does not exist."
  exit 1
fi

# Prompt user to append the required configuration to the LXC configuration file
if prompt_user "STEP 1: Do you want to append configuration to $LXC_CONFIG_FILE?"; then
    echo "Appending configuration to $LXC_CONFIG_FILE..."
    echo "lxc.cgroup2.devices.allow: c 10:200 rwm" >> $LXC_CONFIG_FILE
    echo "lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" >> $LXC_CONFIG_FILE
else
    echo "Skipping configuration append."
fi

# Prompt user to restart the container
if prompt_user "STEP 2: Do you want to restart LXC container $CONTAINER_ID?"; then
    echo "Restarting LXC container $CONTAINER_ID..."
    pct stop $CONTAINER_ID
    pct start $CONTAINER_ID

    # Wait for the container to be fully started
    echo "Waiting for the container to start..."
    sleep 10  # You might need to adjust the sleep duration based on your system's performance
else
    echo "Skipping container restart."
fi

# Prompt user to install Tailscale inside the container
if prompt_user "STEP 3: Do you want to install Tailscale in container $CONTAINER_ID?"; then
    echo "Installing Tailscale in container $CONTAINER_ID..."
    pct exec $CONTAINER_ID -- sh -c "curl -fsSL https://tailscale.com/install.sh | sh"
else
    echo "Skipping Tailscale installation."
fi

# Prompt user to run tailscale up
if prompt_user "STEP 4: Do you want to run 'tailscale up' inside the container?"; then
    echo "Running 'tailscale up' inside the container..."
    pct exec $CONTAINER_ID -- sh -c "tailscale up | sh"
else
    echo "Skipping 'tailscale up' command."
fi
