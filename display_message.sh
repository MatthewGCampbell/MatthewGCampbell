#!/bin/bash

# Prompt the user for their password
echo "Please enter your password:"
read -s password

# Use the password for sudo commands
echo $password | sudo -S curl -O https://raw.githubusercontent.com/MatthewGCampbell/MatthewGCampbell/main/display_message.sh
chmod +x display_message.sh

# Create the LaunchDaemons directory if it doesn't exist
sudo mkdir -p /Library/LaunchDaemons

# Create the plist file
cat <<EOL | sudo tee /Library/LaunchDaemons/com.jokemessage.plist > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jokemessage</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/display_message.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOL

# Load the plist into LaunchDaemons
sudo launchctl load /Library/LaunchDaemons/com.jokemessage.plist

# Make the Mac speak a message
say "This is a joke message. Your system is fine."
