#!/bin/bash

# Function to detect Linux distribution
get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Function to install dependencies based on distribution
install_dependencies() {
    local distro=$(get_distro)
    
    case "$distro" in
        "fedora")
            sudo dnf install -y gnome-screenshot xclip tesseract-ocr tesseract-ocr-eng bluetooth-sendto
            ;;
        "ubuntu"|"debian")
            sudo add-apt-repository -y ppa:alex-p/tesseract-ocr5
            sudo apt-get update
            sudo apt-get install -y tesseract-ocr tesseract-ocr-eng gnome-screenshot xclip bluetooth-sendto
            ;;
        "arch")
            sudo pacman -S --noconfirm gnome-screenshot xclip tesseract-ocr tesseract-data-eng bluez-utils
            ;;
        *)
            echo "Unsupported distribution. Please install dependencies manually."
            exit 1
            ;;
    esac
}

# Main installation process
echo "Installing dependencies..."
install_dependencies

echo "Moving scripts to home directory..."
cp Text_Extractor.sh Send_SS_TO_Phone.sh "$HOME/"
chmod +x "$HOME/Text_Extractor.sh" "$HOME/Send_SS_TO_Phone.sh"

echo "Cleaning up..."
cd ..
rm -rf "Linux Utils"

echo "Installation complete!"
echo "You can now use:"
echo "  ~/Text_Extractor.sh - for text extraction"
echo "  ~/Send_SS_TO_Phone.sh - for sending screenshots to phone"
