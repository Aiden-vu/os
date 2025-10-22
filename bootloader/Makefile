BUILD_DIR=../build/bootloader

all: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: bootloader.asm
	@mkdir -p $(BUILD_DIR)
	nasm -f bin bootloader.asm -o $(BUILD_DIR)/bootloader.bin

clean:
	rm -f $(BUILD_DIR)/*