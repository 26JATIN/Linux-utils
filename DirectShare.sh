#!/bin/bash

# Check dependencies
if ! command -v qrencode &> /dev/null || ! command -v feh &> /dev/null; then
    echo "Installing required dependencies..."
    sudo apt-get update && sudo apt-get install -y qrencode feh xclip libnotify-bin python3
fi

# Try to get file paths from both primary selection and clipboard
FILE_PATHS=$(xclip -o -selection primary 2>/dev/null || echo "")

if [ -z "$FILE_PATHS" ]; then
    # Try clipboard if primary selection is empty
    FILE_PATHS=$(xclip -o -selection clipboard 2>/dev/null || echo "")
fi

# Remove file:// prefix and clean paths
FILE_LIST=()
while IFS= read -r line; do
    # Clean up the path
    clean_path=${line#file://}
    clean_path=$(echo "$clean_path" | xargs)
    
    # Check if it's a valid file
    if [ -f "$clean_path" ]; then
        FILE_LIST+=("$clean_path")
    fi
done <<< "$FILE_PATHS"

# Verify if we have valid files
if [ ${#FILE_LIST[@]} -eq 0 ]; then
    notify-send "DirectShare" "No files selected! Please select file(s) in the file manager first."
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
mkdir -p "$TEMP_DIR/files"

# Create zip file if multiple files, otherwise use single file
if [ ${#FILE_LIST[@]} -gt 1 ]; then
    ZIP_NAME="shared_files.zip"
    cd "$TEMP_DIR/files" || exit
    for file in "${FILE_LIST[@]}"; do
        ln -s "$file" "$(basename "$file")"
    done
    cd ..
    zip -rj "files/$ZIP_NAME" "files/"*
    DOWNLOAD_PATH="./files/$ZIP_NAME"
    DISPLAY_NAME="$ZIP_NAME (${#FILE_LIST[@]} files)"
else
    ln -s "${FILE_LIST[0]}" "$TEMP_DIR/files/$(basename "${FILE_LIST[0]}")"
    DOWNLOAD_PATH="./files/$(basename "${FILE_LIST[0]}")"
    DISPLAY_NAME="$(basename "${FILE_LIST[0]}")"
fi

# Create HTML file with download button and file list
cat > "$TEMP_DIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DirectShare Download</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
        }
        .container {
            text-align: center;
            padding: 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .download-btn {
            display: inline-block;
            padding: 15px 30px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 20px;
            font-size: 18px;
        }
        .filename {
            color: #333;
            margin: 10px 0;
            word-break: break-all;
        }
        .file-list {
            text-align: left;
            margin: 20px auto;
            max-width: 400px;
            padding: 10px;
            background: #f8f8f8;
            border-radius: 5px;
        }
        .file-list h3 {
            margin-top: 0;
            color: #666;
        }
        .file-list ul {
            margin: 0;
            padding-left: 20px;
            color: #555;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>DirectShare Download</h2>
        <div class="file-list">
            <h3>Selected Files:</h3>
            <ul>
EOF

# Add file list to HTML
for file in "${FILE_LIST[@]}"; do
    echo "<li>$(basename "$file")</li>" >> "$TEMP_DIR/index.html"
done

# Complete the HTML file
cat >> "$TEMP_DIR/index.html" << EOF
            </ul>
        </div>
        <a href="$DOWNLOAD_PATH" class="download-btn" download>Download $([ ${#FILE_LIST[@]} -gt 1 ] && echo "All Files" || echo "File")</a>
    </div>
</body>
</html>
EOF

# Get local IP and update URL
LOCAL_IP=$(hostname -I | awk '{print $1}')
PORT=8000
URL="http://${LOCAL_IP}:${PORT}/"

# Generate QR code with larger size and white border
qrencode -s 20 -m 2 --foreground=000000 --background=FFFFFF -o /tmp/qr.png "$URL" || {
    notify-send "DirectShare" "Failed to generate QR code!"
    exit 1
}

# Make sure QR code is readable
chmod 644 /tmp/qr.png

# Start HTTP server before showing QR
cd "$TEMP_DIR" || exit
python3 -m http.server $PORT &
SERVER_PID=$!

# Show notification before QR display
notify-send "DirectShare" "Sharing: $DISPLAY_NAME\nScan QR code to download\nPress q to stop sharing"

# Display QR code in a resizable window
feh --title "DirectShare - Press q to quit" \
    --image-bg white \
    --scale-down \
    --geometry 500x500 \
    --auto-zoom \
    --force-aliasing \
    --zoom 100 \
    /tmp/qr.png

# Cleanup
kill $SERVER_PID 2>/dev/null
rm -f /tmp/qr.png
rm -rf "$TEMP_DIR"
notify-send "DirectShare" "File sharing stopped"
