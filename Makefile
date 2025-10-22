BUILD_DIR=build
BOOTLOADER=$(BUILD_DIR)/bootloader/bootloader.bin
KERNEL=$(BUILD_DIR)/kernel/kernel.bin
DISK_IMG=disk.img

# Disk parameters
SECTORS_PER_TRACK=18
HEADS=2
TRACKS=80
TOTAL_SECTORS=2880

all: setup bootdisk

.PHONY: setup bootdisk bootloader kernel clean run debug

# Create build directories
setup:
	@mkdir -p $(BUILD_DIR)/bootloader
	@mkdir -p $(BUILD_DIR)/kernel

bootloader: setup
	$(MAKE) -C bootloader

kernel: setup
	$(MAKE) -C kernel

bootdisk: bootloader kernel
	@echo "Creating disk image..."
	dd if=/dev/zero of=$(DISK_IMG) bs=512 count=$(TOTAL_SECTORS) 2>/dev/null
	dd conv=notrunc if=$(BOOTLOADER) of=$(DISK_IMG) bs=512 count=1 seek=0 2>/dev/null
	dd conv=notrunc if=$(KERNEL) of=$(DISK_IMG) bs=512 count=10 seek=1 2>/dev/null
	@echo "Disk image created: $(DISK_IMG)"

run: bootdisk
	qemu-system-i386 -fda $(DISK_IMG)

debug: bootdisk
	qemu-system-i386 -fda $(DISK_IMG) -gdb tcp::26000 -S

monitor: bootdisk
	qemu-system-i386 -fda $(DISK_IMG) -monitor stdio

clean:
	$(MAKE) -C bootloader clean
	$(MAKE) -C kernel clean
	rm -f $(DISK_IMG)
	rm -rf $(BUILD_DIR)