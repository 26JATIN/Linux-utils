#!/bin/bash

# Check dependencies
if ! command -v qrencode &> /dev/null || ! command -v feh &> /dev/null; then
    echo "Installing required dependencies..."
    sudo apt-get update && sudo apt-get install -y qrencode feh python3 xclip
fi

# Try to get file path from clipboard
CLIPBOARD=$(xclip -o -selection clipboard 2>/dev/null || echo "")
FILE_PATH=""

if [ -n "$CLIPBOARD" ] && [ -f "$CLIPBOARD" ]; then
    # Use the file path from clipboard
    FILE_PATH="$CLIPBOARD"
else
    # If no valid file in clipboard, use file selector
    FILE_PATH=$(zenity --file-selection --title="Select a file to share")
fi

if [ -z "$FILE_PATH" ]; then
    echo "No file selected"
    exit 1
fi

# Get local IP address
LOCAL_IP=$(hostname -I | awk '{print $1}')
PORT=8000
URL="http://${LOCAL_IP}:${PORT}/$(basename "$FILE_PATH")"

# Create temporary directory and symlink the file
TEMP_DIR=$(mktemp -d)
ln -s "$FILE_PATH" "$TEMP_DIR/$(basename "$FILE_PATH")"

# Generate and display QR code
qrencode -s 10 -o /tmp/qr.png "$URL"
feh --fullscreen /tmp/qr.png &
FEH_PID=$!

# Start Python HTTP server in background
cd "$TEMP_DIR" || exit
python3 -m http.server $PORT &
SERVER_PID=$!

# Wait for user to press any key
read -n 1 -s -r -p "Press any key to stop sharing..."

# Cleanup
kill $SERVER_PID
kill $FEH_PID
rm /tmp/qr.png
rm -rf "$TEMP_DIR"
