#!/bin/bash
# A simple script to allow you to pull down the Mellanox Drivers from HPe and flash your HPe SKU Mellanox Cards

LOG_FILE="/var/log/firmware_update.log"
FW_DOWNLOAD="https://downloads.hpe.com/pub/softlib2/software1/pubsw-linux/p61794168/v276229/fw-ConnectX4-rel-12_28_4704-825111-B21_Ax_Bx-UEFI-14.21.21-FlexBoot-3.6.103.bin"
FW_FILE="/tmp/fw-ConnectX4-rel-12_28_4704-825111-B21_Ax_Bx-UEFI-14.21.21-FlexBoot-3.6.103.bin"

CURRENT_FW=$(ibdev2netdev -v | grep ib0 | awk '{print $14}')
echo "Current firmware version: $CURRENT_FW" | tee -a "$LOG_FILE"
if (echo "$CURRENT_FW" | grep -q "12.28.4704"); then
    echo "Firmware is already up to date. No update needed." | tee -a "$LOG_FILE"
    exit 0
else
    echo "Firmware is outdated. Proceeding with update..." | tee -a "$LOG_FILE"
fi

# Download the firmware file from HPe and save it to /tmp directory
curl -fL -o "$FW_FILE" "$FW_DOWNLOAD" | tee -a "$LOG_FILE"

# Use the flint tool to burn the firmware to the devices
flint -d 10:00.0 -i "$FW_FILE" burn && flint -d 86:00.0 -i "$FW_FILE" burn | tee -a "$LOG_FILE"
