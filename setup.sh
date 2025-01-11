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

# Function to create keyboard shortcuts using gsettings
create_shortcuts() {
    # Get the full path of the scripts
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TEXT_SCRIPT="$SCRIPT_DIR/Text_Extractor.sh"
    SEND_SCRIPT="$SCRIPT_DIR/Send_SS_TO_Phone.sh"

    # Make scripts executable
    chmod +x "$TEXT_SCRIPT" "$SEND_SCRIPT"

    # Get the current custom shortcuts
    current=$((gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings | grep -o "\[.*\]") 2>/dev/null || echo "[]")
    
    # Remove the brackets
    current=${current#[}
    current=${current%]}
    
    # Add new paths
    if [ "$current" = "" ]; then
        new_paths="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/'"
    else
        new_paths="$current, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/'"
    fi
    
    # Update the custom shortcuts list
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[$new_paths]"
    
    # Set up Text Extractor shortcut (Super+T)
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Text Extractor"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "$TEXT_SCRIPT"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super>t"
    
    # Set up Send Screenshot shortcut (Super+S)
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "Send Screenshot"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "$SEND_SCRIPT"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Super>s"
}

# Main installation process
echo "Installing dependencies..."
install_dependencies

echo "Setting up keyboard shortcuts..."
create_shortcuts

echo "Installation complete!"
echo "Keyboard shortcuts created:"
echo "  Super+T - Text Extractor"
echo "  Super+S - Send Screenshot to Phone"
