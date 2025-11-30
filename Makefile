# Makefile
# Build the OS image

all: os-image.bin

os-image.bin: boot.bin kernel.bin
	cat boot.bin kernel.bin > os-image.raw
	dd if=/dev/zero of=os-image.bin bs=512 count=20
	dd if=os-image.raw of=os-image.bin conv=notrunc
	rm os-image.raw

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

kernel.bin: kernel_entry.o kernel.o
	ld -m elf_i386 -o kernel.bin -T link.ld kernel_entry.o kernel.o --oformat binary

kernel_entry.o: kernel_entry.asm
	nasm -f elf kernel_entry.asm -o kernel_entry.o

kernel.o: kernel.c
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o -fno-pie

clean:
	rm -f *.bin *.o

run: os-image.bin
	qemu-system-x86_64 -drive format=raw,file=os-image.bin
