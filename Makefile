.PHONY: all build test clean install help

# Default target
all: build

# Build the ISO
build:
	@echo "Building USB Wiper ISO..."
	./build-iso.sh

# Test the wipe script (dry run)
test:
	@echo "Testing wipe script (no actual wiping)..."
	@echo "YES" | ./scripts/wipe-test.sh

# Test the actual wipe script detection only
test-detection:
	@echo "Testing USB drive detection..."
	@./scripts/wipe.sh || true

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf iso-build/
	rm -f usb-wiper.iso*

# Install required packages (requires sudo)
install-deps:
	@echo "Installing required packages..."
	sudo apt update
	sudo apt install -y genisoimage isolinux syslinux-utils

# Verify ISO contents
verify:
	@if [ -f usb-wiper.iso ]; then \
		echo "Verifying ISO contents..."; \
		isoinfo -l -i usb-wiper.iso | head -20; \
		echo "ISO size: $$(du -h usb-wiper.iso | cut -f1)"; \
		echo "SHA256: $$(cat usb-wiper.iso.sha256 | cut -d' ' -f1)"; \
	else \
		echo "ISO file not found. Run 'make build' first."; \
	fi

# Make scripts executable
chmod:
	chmod +x scripts/*.sh
	chmod +x build-iso.sh

# Help target
help:
	@echo "USB Drive Wiper Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  build          Build the ISO image"
	@echo "  test           Test the wipe script (dry run)"
	@echo "  test-detection Test USB drive detection only"
	@echo "  clean          Clean build artifacts"
	@echo "  install-deps   Install required packages"
	@echo "  verify         Verify ISO contents"
	@echo "  chmod          Make scripts executable"
	@echo "  help           Show this help message"
	@echo ""
	@echo "WARNING: The actual wipe script will PERMANENTLY DELETE data!"
	@echo "Only use on drives you want to completely erase."

