#!/bin/bash

# USB Drive Wiper Script - TEST VERSION
# This script will show what would be wiped without actually doing it

set -e

echo "=== USB Drive Wiper - TEST MODE ==="
echo "WARNING: This would PERMANENTLY ERASE all data on USB drives!"
echo "TEST MODE: No actual wiping will occur"
echo

# Function to detect USB drives
detect_usb_drives() {
    echo "Detecting USB drives..."
    USB_DRIVES=$(lsblk -S -o NAME,TRAN,SIZE,MODEL | grep usb | awk '{print "/dev/"$1}' || true)
    
    if [ -z "$USB_DRIVES" ]; then
        echo "No USB drives detected."
        return 1
    fi
    
    echo "Found USB drives:"
    lsblk -S -o NAME,TRAN,SIZE,MODEL | grep usb
    echo
    
    return 0
}

# Function to simulate wiping a drive
wipe_drive_test() {
    local drive=$1
    echo "[TEST] Would wipe drive: $drive"
    
    # Show what would be unmounted
    echo "[TEST] Would unmount partitions on: ${drive}*"
    
    # Show what wipefs would do
    echo "[TEST] Would run: wipefs -a $drive"
    
    # Show what dd would do
    echo "[TEST] Would run: dd if=/dev/zero of=$drive bs=1M count=10"
    
    # Show partprobe command
    echo "[TEST] Would run: partprobe $drive"
    
    echo "[TEST] Drive $drive would be wiped successfully."
    echo
}

# Main execution
echo "Starting USB drive detection..."
echo

if ! detect_usb_drives; then
    echo "No USB drives to wipe. Exiting..."
    echo "[TEST] This is the expected behavior when no USB drives are connected."
    read -p "Press Enter to continue..."
    exit 0
fi

echo "The following USB drives would be PERMANENTLY ERASED:"
echo "$USB_DRIVES"
echo
echo "WARNING: This action cannot be undone!"
echo "All data on these drives will be lost forever!"
echo

# Interactive mode - ask for confirmation
read -p "Do you want to proceed with TEST MODE? Type 'YES' to confirm: " confirmation

if [ "$confirmation" != "YES" ]; then
    echo "Operation cancelled."
    read -p "Press Enter to continue..."
    exit 0
fi

echo
echo "Starting TEST wipe process..."
echo

# Test wipe each detected USB drive
for drive in $USB_DRIVES; do
    if [ -b "$drive" ]; then
        wipe_drive_test "$drive"
    else
        echo "[TEST] Warning: $drive is not a valid block device, would skip..."
    fi
done

echo "=== TEST Wipe operation completed ==="
echo "All USB drives would have been wiped."
echo "[TEST] No actual wiping occurred - this was a test run."
echo
if [ -t 0 ]; then
    read -p "Press Enter to exit..."
else
    echo "[TEST] Automated mode - exiting without waiting for input."
fi

