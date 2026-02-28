#!/usr/bin/env bash

set -e

# Configuration
REPO_URL="https://github.com/gworkman/usb_fel_loaders"
VERSION=$(cat "$(dirname "$0")/VERSION" 2>/dev/null || echo "latest")

trap abort_int INT
function abort_int() {
    tput cnorm
    exit 0
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RELEASE_DIR="$SCRIPT_DIR/release"

if [ "$#" -ne 1 ]; then
    echo "Usage: ./launch.sh [Board Name]"
    echo ""
    echo "Example board names:"
    echo ""
    echo "  trellis"
    echo "  pine64"
    exit 1
fi

BOARD_ID=$1
UBOOT_LOADER="$RELEASE_DIR/$BOARD_ID.bin"

# 1. Check for sunxi-fel
if ! [ -x "$(command -v sunxi-fel)" ]; then
  echo 'Error: sunxi-fel was not found in your PATH!' >&2
  exit 1
fi

# 2. Ensure boards directory exists
mkdir -p "$RELEASE_DIR"

# 3. Auto-download logic if .bin is missing
if [ ! -f "$UBOOT_LOADER" ]; then
    echo "Board loader '$BOARD_ID.bin' not found locally."
    
    # If VERSION file is missing, we use 'latest'
    RELEASE_TAG="$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "latest")"
    if [ "$RELEASE_TAG" == "latest" ]; then
        DOWNLOAD_URL="$REPO_URL/releases/latest/download/$BOARD_ID.bin"
    else
        DOWNLOAD_URL="$REPO_URL/releases/download/$RELEASE_TAG/$BOARD_ID.bin"
    fi

    echo "Attempting to download from GitHub: $DOWNLOAD_URL"
    
    if command -v curl >/dev/null 2>&1; then
        curl -L "$DOWNLOAD_URL" -o "$UBOOT_LOADER" --fail || { echo "Download failed!"; exit 1; }
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$UBOOT_LOADER" "$DOWNLOAD_URL" || { echo "Download failed!"; exit 1; }
    else
        echo "Error: curl or wget is required to download missing board files." >&2
        exit 1
    fi
    echo "Successfully downloaded $BOARD_ID.bin"
fi

echo ""
echo "==========================="
echo "    USB FEL Loader         "
echo "==========================="
echo ""
echo "[!!] THIS WILL ERASE THE DEVICE'S CURRENT FIRMWARE UPON CONNECTING [!!]"
echo ""
echo "Target Board: $BOARD_ID"
echo ""
echo "Please place your board in FEL mode and connect it to your machine..."
echo ""

spinner="/-\|"
spin_index=1
tput civis
until sunxi-fel version > /dev/null 2>&1
do
    printf "\bWaiting for board... (Ctrl+C to Abort) [${spinner:i++%${#spinner}:1}]\r"
    sleep 0.5
done
tput cnorm

BOARD_FEL_VERSION=$(sunxi-fel version)

echo -e "\n"
echo "Board found! [$BOARD_FEL_VERSION]"
echo ""
echo "Loading USB loader over FEL USB..."

echo "sunxi-fel uboot $UBOOT_LOADER"
sunxi-fel uboot "$UBOOT_LOADER"

echo ""
echo "Waiting a moment for the eMMC to be erased..."
sleep 5
echo "DONE!"
echo "Your board should show up as a USB Storage Device in a few seconds..."
