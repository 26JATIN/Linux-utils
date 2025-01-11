#!/bin/bash

screenshot_file="$HOME/Pictures/screenshot.png"

gnome-screenshot --area --file="$screenshot_file"

if [ -f "$screenshot_file" ]; then
    chmod +r "$screenshot_file"

    connected_phones=$(bluetoothctl devices | while read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        
        if bluetoothctl info "$mac" | grep -q "Connected: yes" && \
           bluetoothctl info "$mac" | grep -q "Icon: phone"; then
            echo "$mac"
        fi
    done)

    if [ -z "$connected_phones" ]; then
        echo "No connected phones found."
        exit 1
    fi

    for device in $connected_phones; do
        echo "Sending screenshot to phone with MAC address $device..."
        bluetooth-sendto --device="$device" "$screenshot_file"
        
        if [ $? -eq 0 ]; then
            echo "Screenshot sent to phone with MAC address $device successfully."
        else
            echo "Failed to send the screenshot to phone with MAC address $device."
        fi
    done

    rm "$screenshot_file"
else
    echo "Error: Unable to capture screenshot."
fi
