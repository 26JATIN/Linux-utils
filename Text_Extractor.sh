#!/bin/bash

perform_ocr() {
    local img_path="$1"

    result=$(tesseract "$img_path" stdout)

    echo -n "$result" | xclip -selection clipboard
    echo "Recognized Text: $result (copied to clipboard)"
}

screenshot_file="/tmp/screenshot.png"
gnome-screenshot --area --file="$screenshot_file"

if [ -f "$screenshot_file" ]; then
    perform_ocr "$screenshot_file"

    rm "$screenshot_file"
else
    echo "Error: Unable to capture screenshot."
fi
