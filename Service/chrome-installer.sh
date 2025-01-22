#!/bin/bash
set -e

# Download Chromium package
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

# Install it
rpm -i google-chrome-stable_current_x86_64.rpm

# Download the chromedriver version matching your Chromium version
wget https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip

# Unzip the downloaded file
unzip chromedriver_linux64.zip

# Move chromedriver to a suitable directory
mv chromedriver /usr/local/bin/

export CHROME_BIN=/usr/bin/google-chrome-stable