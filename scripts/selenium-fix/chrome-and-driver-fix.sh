#!/bin/bash

# Author github.com/hassankhurram
# Created @ 2023-11-13 10:22:14
# Description: This script installs the latest version of Chrome on WSL2.
# It downloads the browser and driver from Google's official website.
# It then moves the browser and driver to the appropriate locations.
# It also sets the permissions for the browser and driver.
# This script is for educational purposes only.
# Please use it responsibly.

# Set the Chrome version to download.

CHROMIUM_VERSION="128.0.6613.84" # update the version here.

function cleanupChromeBrowser {
    rm -f chrome-linux64.zip
    rm -rf chrome-browser 
}

function cleanupChromeDriver {
    rm -f chromedriver-linux64.zip
    rm -rf chromedriver-linux64 
}
echo "initialization"node 
sudo apt update
sudo apt install -y wget gnupg

echo "Downloading Chrome Browser"
cleanupChromeBrowser
wget https://storage.googleapis.com/chrome-for-testing-public/$CHROMIUM_VERSION/linux64/chrome-linux64.zip
unzip chrome-linux64.zip
mv chrome-linux64 chrome-browser
sudo mv chrome-browser/chrome /usr/bin/chrome
sudo chmod +x /usr/bin/chrome
cleanupChromeBrowser

echo "Downloading Chrome Driver"
cleanupChromeDriver
wget https://storage.googleapis.com/chrome-for-testing-public/$CHROMIUM_VERSION/linux64/chromedriver-linux64.zip
unzip chromedriver-linux64.zip
sudo mv chromedriver-linux64/chromedriver /usr/local/bin/chromedriver
sudo chmod +x /usr/local/bin/chromedriver
cleanupChromeDriver

echo "Installed Chrome on WSL2"
