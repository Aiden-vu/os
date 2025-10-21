all: bootloader bootdisk

bootloader:
	nasm -f bin bootloader.asm -o bootloader.o

kernel:
	nasm -f bin sample.asm -o sample.o

bootdisk: bootloader kernel
	dd if=/dev/zero of=disk.img bs=512 count=2880
	dd conv=notrunc if=bootloader.o of=disk.img bs=512 count=1 seek=0
	dd conv=notrunc if=sample.o of=disk.img bs=512 count=1 seek=1
