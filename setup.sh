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
    
    echo "Installing dependencies for $distro..."
    
    case "$distro" in
        "fedora")
            # First install basic tools
            sudo dnf install -y epel-release
            sudo dnf update -y
            sudo dnf install -y gnome-screenshot xclip tesseract tesseract-langpack-eng \
                              bluez bluez-tools
            # Then install DirectShare specific dependencies
            sudo dnf install -y qrencode feh python3 zenity zip libnotify
            ;;
        "ubuntu"|"debian")
            # Update package list
            sudo apt-get update
            # First install basic tools
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository -y ppa:alex-p/tesseract-ocr5
            sudo apt-get update
            sudo apt-get install -y tesseract-ocr tesseract-ocr-eng gnome-screenshot xclip \
                                  bluetooth bluez bluez-tools
            # Then install DirectShare specific dependencies
            sudo apt-get install -y qrencode feh python3 zenity zip libnotify-bin
            ;;
        "arch")
            # Update package list
            sudo pacman -Sy
            # Install all dependencies
            sudo pacman -S --noconfirm gnome-screenshot xclip tesseract tesseract-data-eng \
                                      bluez bluez-utils qrencode feh python zenity zip libnotify
            ;;
        *)
            echo "Unsupported distribution. Please install dependencies manually."
            exit 1
            ;;
    esac

    # Verify installation
    echo "Verifying installations..."
    local required_commands=(
        "gnome-screenshot:gnome-screenshot"
        "xclip:xclip"
        "tesseract:tesseract-ocr"
        "qrencode:qrencode"
        "feh:feh"
        "python3:python3"
        "zip:zip"
        "notify-send:libnotify-bin"
    )

    local missing_packages=()
    for cmd_pair in "${required_commands[@]}"; do
        IFS=':' read -r cmd pkg <<< "$cmd_pair"
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_packages+=("$pkg")
        fi
    done

    if [ ${#missing_packages[@]} -ne 0 ]; then
        echo "Error: Some required packages are still missing:"
        printf '%s\n' "${missing_packages[@]}"
        echo "Please try installing them manually:"
        case "$distro" in
            "fedora")
                echo "sudo dnf install ${missing_packages[*]}"
                ;;
            "ubuntu"|"debian")
                echo "sudo apt-get install ${missing_packages[*]}"
                ;;
            "arch")
                echo "sudo pacman -S ${missing_packages[*]}"
                ;;
        esac
        exit 1
    fi

    echo "All dependencies installed successfully!"
}

# Function to create keyboard shortcuts using gsettings
create_shortcuts() {
    # Get the full path of the scripts
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TEXT_SCRIPT="$SCRIPT_DIR/Text_Extractor.sh"
    SEND_SCRIPT="$SCRIPT_DIR/Send_SS_TO_Phone.sh"
    SHARE_SCRIPT="$SCRIPT_DIR/DirectShare.sh"

    # Make scripts executable
    chmod +x "$TEXT_SCRIPT" "$SEND_SCRIPT" "$SHARE_SCRIPT"

    # Get the current custom shortcuts
    current=$((gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings | grep -o "\[.*\]") 2>/dev/null || echo "[]")
    
    # Remove the brackets
    current=${current#[}
    current=${current%]}
    
    # Add new paths
    if [ "$current" = "" ]; then
        new_paths="'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/'"
    else
        new_paths="$current, '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/'"
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
    
    # Set up DirectShare shortcut (Super+D)
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name "DirectShare"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command "$SHARE_SCRIPT"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding "<Super>d"
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
echo "  Super+D - DirectShare"
