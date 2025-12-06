#!/bin/bash

set -e

SCRIPT_URL="https://raw.githubusercontent.com/MatthewGCampbell/MatthewGCampbell/main/display_message.sh"
SCRIPT_PATH="/usr/local/bin/joke_display_message.sh"
PLIST_PATH="/Library/LaunchDaemons/com.jokemessage.plist"
PASSWORD=$1  # Capture the password passed as an argument

# If not root, re-exec with sudo
if [[ "$EUID" -ne 0 ]]; then
  echo "This script needs sudo/root. Re-running with sudo..."
  exec sudo "$0" "$@"
fi

echo "Downloading message script to $SCRIPT_PATH ..."
curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH"

# Make the message script JUST say something
cat <<'MSG' > "$SCRIPT_PATH"
#!/bin/bash
/usr/bin/say "This is a joke message. Your system is fine."
MSG

chmod 755 "$SCRIPT_PATH"

echo "Creating LaunchDaemon plist at $PLIST_PATH ..."
cat <<EOL > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jokemessage</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOL

chown root:wheel "$PLIST_PATH"
chmod 644 "$PLIST_PATH"

# Unload if already loaded (ignore errors), then load
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

# Test speech immediately
/usr/bin/say "This is a joke message. Your system is fine."
