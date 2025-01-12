# Linux Screenshot Utilities

This repository contains three useful utilities for Linux:
1. Text Extractor - Extract text from screenshots using OCR
2. Screenshot to Phone - Send screenshots directly to your phone via Bluetooth
3. DirectShare - Share files instantly over local network using QR codes

## Installation

Simply run:
```bash
git clone https://github.com/26JATIN/Linux-utils.git
cd Linux-utils
chmod +x setup.sh
./setup.sh
```

The setup script will:
- Automatically detect your Linux distribution
- Install all required dependencies
- Create keyboard shortcuts automatically:
  - Super+T for Text Extractor
  - Super+S for Screenshot to Phone
  - Super+D for DirectShare

## Usage

### Text Extractor
1. Press Super+T (Windows/Command key + T)
2. Select the area you want to capture text from
3. The text will be automatically copied to your clipboard

### Screenshot to Phone
1. Make sure your phone is connected via Bluetooth
2. Press Super+S (Windows/Command key + S)
3. Select the area you want to capture
4. The screenshot will be sent to your connected phone

### DirectShare
1. Select a file in your file manager
2. Press Super+D to share
3. A QR code will appear on your screen
4. Scan the QR code with any device on the same network
5. The file will be downloaded automatically
6. Press any key to stop sharing

Note: Make sure to select the file you want to share before pressing Super+D
