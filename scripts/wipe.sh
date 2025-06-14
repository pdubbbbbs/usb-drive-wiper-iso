#!/bin/bash

# USB Drive Wiper Script
# This script will wipe all filesystem signatures from detected USB drives

set -e

echo "=== USB Drive Wiper ==="
echo "WARNING: This will PERMANENTLY ERASE all data on USB drives!"
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

# Function to wipe a drive
wipe_drive() {
    local drive=$1
    echo "Wiping drive: $drive"
    
    # Unmount all partitions on the drive
    echo "Unmounting partitions..."
    umount ${drive}* 2>/dev/null || true
    
    # Use wipefs to remove all filesystem signatures
    echo "Removing filesystem signatures..."
    wipefs -a "$drive"
    
    # Zero out the first few MB to be thorough
    echo "Zeroing partition table..."
    dd if=/dev/zero of="$drive" bs=1M count=10 2>/dev/null
    
    # Force kernel to re-read partition table
    partprobe "$drive" 2>/dev/null || true
    
    echo "Drive $drive has been wiped successfully."
    echo
}

# Main execution
echo "Starting USB drive detection..."
echo

if ! detect_usb_drives; then
    echo "No USB drives to wipe. Exiting..."
    read -p "Press Enter to continue..."
    exit 0
fi

echo "The following USB drives will be PERMANENTLY ERASED:"
echo "$USB_DRIVES"
echo
echo "WARNING: This action cannot be undone!"
echo "All data on these drives will be lost forever!"
echo

# Interactive mode - ask for confirmation
read -p "Do you want to proceed? Type 'YES' to confirm: " confirmation

if [ "$confirmation" != "YES" ]; then
    echo "Operation cancelled."
    read -p "Press Enter to continue..."
    exit 0
fi

echo
echo "Starting wipe process..."
echo

# Wipe each detected USB drive
for drive in $USB_DRIVES; do
    if [ -b "$drive" ]; then
        wipe_drive "$drive"
    else
        echo "Warning: $drive is not a valid block device, skipping..."
    fi
done

echo "=== Wipe operation completed ==="
echo "All USB drives have been wiped."
echo
read -p "Press Enter to reboot..."
reboot

