#!/bin/bash

# #####################################################################
#
#  WARNING: THIS SCRIPT WILL NOT WORK ON YOUR RMX3063 PHONE.
#
#  Your phone has Dynamic Partitions (`super.img`) but BLOCKS access
#  to the required `fastbootd` mode. Therefore, the `fastboot flash super`
#  command is guaranteed to fail with a "partition not found" or
#  similar error.
#
#  This script is provided for educational purposes only to show what
#  the commands would look like.
#
#  YOU MUST USE THE SP FLASH TOOL SCRIPT TO FLASH YOUR PHONE.
#
# #####################################################################


# --- Configuration ---
# Make sure this path points to your extracted firmware files.
FIRMWARE_DIR="/home/itachi/Public/rmx3063/flash/oppo_decrypt/extracted_firmware"
# --- End of Configuration ---


echo "---------------------------------------------------------"
echo "Attempting to flash with fastboot..."
echo "WARNING: This is expected to FAIL on the 'super' partition."
echo "---------------------------------------------------------"

# Navigate to the firmware directory
if [ ! -d "$FIRMWARE_DIR" ]; then
    echo "❌ ERROR: Firmware directory not found. Edit the script."
    exit 1
fi
cd "$FIRMWARE_DIR"


echo "Flashing userdata..."
fastboot flash userdata userdata.img
echo "Flashing super..."
fastboot flash super super.img
echo "Flashing boot..."
fastboot flash boot boot.img
echo "Flashing dtbo..."
fastboot flash dtbo dtbo.img
echo "Flashing vbmeta..."
fastboot flash vbmeta vbmeta.img
echo "Flashing recovery..."

echo "Flashing tee..."
fastboot flash tee tee.img

# This is the command that is technically impossible on your device
echo "---------------------------------------------------------"
echo "Attempting to flash the super partition..."
echo "THIS COMMAND LET'S SEE."
echo "---------------------------------------------------------"

# Check the result
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ As expected, 'fastboot flash super' failed."
    echo "This proves you cannot use fastboot for this process."
    echo "Please use the 'flash_realme.sh' script which uses SP Flash Tool."
    exit 1
fi

echo "Wiping data..."
fastboot -w

echo "Rebooting..."
fastboot reboot

echo "🎉 If you see this message, it's a miracle. But it's more likely the script failed earlier."
