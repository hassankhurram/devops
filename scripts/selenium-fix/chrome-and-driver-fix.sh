#!/bin/bash

# Author: github.com/hassankhurram
# Created: 2023-11-13 10:22:14
# Description: This script installs the specified version of Chrome on WSL2.
# It downloads the browser and driver from Google's official website,
# moves them to the appropriate locations, and sets the necessary permissions.
# This script is for educational purposes only. Use it responsibly.

# Set the Chrome version to download.
CHROMIUM_VERSION="128.0.6613.84" # Update the version here.

# Function to clean up Chrome browser files
function cleanupChromeBrowser {
    rm -f chrome-linux64.zip
    rm -rf chrome-linux64
}

# Function to clean up ChromeDriver files
function cleanupChromeDriver {
    rm -f chromedriver-linux64.zip
    rm -rf chromedriver-linux64
}

# Initialize and update package list
echo "Initializing..."
sudo apt update
sudo apt install -y wget gnupg

# Download and install Chrome browser
echo "Downloading Chrome Browser..."
cleanupChromeBrowser
wget https://storage.googleapis.com/chrome-for-testing-public/$CHROMIUM_VERSION/linux64/chrome-linux64.zip
unzip chrome-linux64.zip
sudo mv chrome-linux64/chrome /usr/bin/chrome
sudo chmod +x /usr/bin/chrome
cleanupChromeBrowser

# Download and install ChromeDriver
echo "Downloading ChromeDriver..."
cleanupChromeDriver
wget https://storage.googleapis.com/chrome-for-testing-public/$CHROMIUM_VERSION/linux64/chromedriver-linux64.zip
unzip chromedriver-linux64.zip
sudo mv chromedriver-linux64/chromedriver /usr/local/bin/chromedriver
sudo chmod +x /usr/local/bin/chromedriver
cleanupChromeDriver

echo "Chrome and ChromeDriver installed on WSL2."
