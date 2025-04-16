#!/usr/bin/env bash

set -e

trap abort_int INT
function abort_int() {
    tput cnorm
    exit 0
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$#" -ne 1 ]; then
    echo "Usage: ./launch.sh [Board Name]"
    echo ""
    echo "Example board names:"
    echo ""
    echo "  trellis"
    echo "  pine64"
    exit 1
fi

if ! [ -x "$(command -v sunxi-fel)" ]; then
  echo 'Error: sunxi-fel was not found in your PATH!' >&2
  exit 1
fi

BOARD_ID=$1
UBOOT_LOADER="$SCRIPT_DIR/boards/$BOARD_ID/u-boot-loader.bin"
BOOT_UENV="$SCRIPT_DIR/boards/$BOARD_ID/boot.uenv"

if [ ! -e "$UBOOT_LOADER" ]; then
    echo "Can't find $UBOOT_LOADER!" >&2
    echo "Check that the board name is right or rebuild it" >&2
    exit 1
fi

if [ -e "$BOOT_UENV" ]; then
   SUNXI_FEL_OPTIONS="write 0x43100000 $BOOT_UENV"
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

echo "\n"
echo "Board found! [$BOARD_FEL_VERSION]"
echo ""
echo "Loading USB loader over FEL USB..."

echo "sunxi-fel uboot $UBOOT_LOADER $SUNXI_FEL_OPTIONS"
sunxi-fel uboot "$UBOOT_LOADER" $SUNXI_FEL_OPTIONS

echo ""
echo "Waiting a moment for the eMMC to be erased..."
sleep 5
echo "DONE!"
echo "Your board should show up as a USB Storage Device in a few seconds..."
