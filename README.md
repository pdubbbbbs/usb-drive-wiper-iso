# USB Drive Wiper ISO

A bootable ISO image that safely wipes/erases USB drives using `wipefs` to remove all filesystem signatures.

## ⚠️ WARNING

**This tool will PERMANENTLY DELETE all data on USB drives!**

Use with extreme caution. This action cannot be undone.

## Features

- Automatically detects USB drives connected to the system
- Uses `wipefs -a` to remove all filesystem signatures
- Unmounts all partitions before wiping
- Zeros out partition tables
- Interactive confirmation to prevent accidental data loss
- Bootable ISO for standalone operation

## Usage

1. Download or build the ISO image
2. Burn the ISO to a CD/DVD or create a bootable USB drive
3. Boot from the CD/DVD/USB
4. Follow the on-screen prompts
5. Confirm the wipe operation by typing 'YES'

## What it does

1. **Detection**: Scans for USB drives using `lsblk`
2. **Unmounting**: Safely unmounts all partitions on detected USB drives
3. **Signature removal**: Uses `wipefs -a` to remove all filesystem signatures
4. **Partition table clearing**: Zeros out the first 10MB of each drive
5. **Kernel notification**: Forces the kernel to re-read partition tables

## Building the ISO

### Quick Build
```bash
# Install dependencies (Ubuntu/Debian)
sudo apt install genisoimage isolinux syslinux-utils

# Build the ISO
make build
# or
./build-iso.sh
```

### Using Makefile
```bash
# Show available commands
make help

# Install dependencies
make install-deps

# Build the ISO
make build

# Test the script (dry run)
make test

# Verify ISO contents
make verify

# Clean build artifacts
make clean
```

### Manual Build
```bash
# Make the script executable
chmod +x scripts/wipe.sh

# Create the ISO (requires genisoimage)
genisoimage -r -V "USB_WIPER" -cache-inodes -J -l \
    -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -o usb-wiper.iso iso-build/
```

## Files Structure

```
wipe-iso/
├── scripts/
│   └── wipe.sh          # Main wiper script
├── boot/
│   └── grub/
│       └── grub.cfg     # GRUB bootloader configuration
├── autorun.inf          # Windows autorun file
└── README.md            # This file
```

## Manual Usage

You can also run the script manually on any Linux system:

```bash
# Make executable
chmod +x scripts/wipe.sh

# Run as root
sudo ./scripts/wipe.sh
```

## Safety Features

- **USB-only targeting**: Only targets drives identified as USB devices
- **Interactive confirmation**: Requires typing 'YES' to proceed
- **Drive listing**: Shows all detected USB drives before wiping
- **Safe mode option**: GRUB menu includes a safe mode boot option

## Requirements

- Linux system with:
  - `wipefs` utility
  - `lsblk` command
  - `dd` command
  - `umount` command
  - `partprobe` utility

## License

MIT License - see LICENSE file for details

## Author

Philip S. Wright

## Disclaimer

This software is provided as-is. The author is not responsible for any data loss or damage caused by the use of this tool. Always backup important data before using any disk wiping utility.

