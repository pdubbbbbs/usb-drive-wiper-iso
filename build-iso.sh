#!/bin/bash

# Local ISO build script for USB Drive Wiper
# This script builds the ISO locally for testing purposes

set -e

echo "=== USB Drive Wiper ISO Builder ==="
echo "Building ISO locally..."
echo

# Check if required tools are installed
command -v genisoimage >/dev/null 2>&1 || { echo "Error: genisoimage not found. Install with: sudo apt install genisoimage"; exit 1; }

# Clean up any previous build
rm -rf iso-build/
rm -f usb-wiper.iso*

# Create build directory structure
echo "Creating build directory structure..."
mkdir -p iso-build/boot/isolinux
mkdir -p iso-build/scripts

# Copy project files
echo "Copying project files..."
cp -r scripts/ iso-build/
cp autorun.inf iso-build/
cp README.md iso-build/
cp LICENSE iso-build/
chmod +x iso-build/scripts/wipe.sh

# For local testing, create a simple isolinux config without actual kernel/initrd
echo "Creating isolinux configuration..."
cat > iso-build/boot/isolinux/isolinux.cfg << 'EOF'
DEFAULT menu.c32
TIMEOUT 50
MENU TITLE USB Drive Wiper

LABEL wiper
MENU LABEL USB Drive Wiper
KERNEL /boot/vmlinuz
APPEND initrd=/boot/initrd.img boot=live username=root init=/scripts/wipe.sh

LABEL wipersafe
MENU LABEL USB Drive Wiper (Safe Mode)
KERNEL /boot/vmlinuz
APPEND initrd=/boot/initrd.img boot=live username=root init=/scripts/wipe.sh single

LABEL shell
MENU LABEL Boot to Shell
KERNEL /boot/vmlinuz
APPEND initrd=/boot/initrd.img boot=live username=root

LABEL reboot
MENU LABEL Reboot
COM32 reboot.c32
EOF

# Check if isolinux files are available
if [ -f /usr/lib/ISOLINUX/isolinux.bin ]; then
    echo "Copying isolinux boot files..."
    cp /usr/lib/ISOLINUX/isolinux.bin iso-build/boot/isolinux/ 2>/dev/null || true
    cp /usr/lib/syslinux/modules/bios/*.c32 iso-build/boot/isolinux/ 2>/dev/null || true
else
    echo "Warning: isolinux files not found. Install with: sudo apt install isolinux syslinux-utils"
    echo "Creating basic ISO without bootloader..."
fi

# Create placeholder kernel/initrd files for testing
echo "Creating placeholder boot files..."
echo "# Placeholder kernel file" > iso-build/boot/vmlinuz
echo "# Placeholder initrd file" > iso-build/boot/initrd.img

# Build the ISO
echo "Building ISO image..."
if [ -f iso-build/boot/isolinux/isolinux.bin ]; then
    # Build bootable ISO
    genisoimage -r -V "USB_WIPER" -cache-inodes -J -l \
        -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        -o usb-wiper.iso iso-build/
else
    # Build data-only ISO
    genisoimage -r -V "USB_WIPER" -cache-inodes -J -l \
        -o usb-wiper.iso iso-build/
fi

# Calculate checksums
echo "Calculating checksums..."
sha256sum usb-wiper.iso > usb-wiper.iso.sha256
md5sum usb-wiper.iso > usb-wiper.iso.md5

# Show results
echo
echo "=== Build Complete ==="
echo "ISO file: $(pwd)/usb-wiper.iso"
echo "Size: $(du -h usb-wiper.iso | cut -f1)"
echo "SHA256: $(cat usb-wiper.iso.sha256 | cut -d' ' -f1)"
echo "MD5: $(cat usb-wiper.iso.md5 | cut -d' ' -f1)"
echo
echo "Files created:"
ls -la usb-wiper.iso*
echo
echo "To test the ISO:"
echo "  - Mount it: sudo mount -o loop usb-wiper.iso /mnt"
echo "  - Or burn it to a CD/USB and boot from it"
echo

