BUILD_DIR=../build/kernel

all: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: kernel.asm include/*.inc
	@mkdir -p $(BUILD_DIR)
	nasm -f bin kernel.asm -o $(BUILD_DIR)/kernel.bin -I./

clean:
	rm -f $(BUILD_DIR)/*