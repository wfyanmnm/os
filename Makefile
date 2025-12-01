# Makefile
# 构建操作系统镜像 (OS Image)

# 默认目标：构建 os-image.bin
all: os-image.bin

# 最终的操作系统镜像 (os-image.bin) 依赖于 引导扇区 (boot.bin) 和 内核 (kernel.bin)
os-image.bin: boot.bin kernel.bin
	# 1. 将 boot.bin 和 kernel.bin 拼接成一个临时文件 os-image.raw
	cat boot.bin kernel.bin > os-image.raw
	
	# 2. 创建一个固定大小 (20个扇区, 10KB) 的空文件 os-image.bin，内容全为 0
	#    if=/dev/zero: 输入源为零设备
	#    of=os-image.bin: 输出文件
	#    bs=512: 块大小为 512 字节 (一个扇区)
	#    count=20: 总共写入 20 个块
	dd if=/dev/zero of=os-image.bin bs=512 count=20
	
	# 3. 将拼接好的代码 (os-image.raw) 覆盖写入到 os-image.bin 的开头
	#    conv=notrunc: 不截断输出文件 (即保留后面未被覆盖的 0)
	#    这样我们就得到了一个固定大小的磁盘镜像，前面是代码，后面是填充的 0
	dd if=os-image.raw of=os-image.bin conv=notrunc
	
	# 4. 删除临时文件
	rm os-image.raw

# 编译引导扇区
# 使用 nasm 将汇编代码编译为纯二进制文件 (Raw Binary)
boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

# 链接内核
# 将内核入口 (kernel_entry.o) 和 C 内核 (kernel.o) 链接在一起
# -m elf_i386: 生成 32 位 ELF 格式对应的指令
# -T link.ld: 使用自定义的链接脚本 link.ld (控制内存布局)
# --oformat binary: 输出为纯二进制格式 (去掉 ELF 头，只保留代码和数据)
kernel.bin: kernel_entry.o kernel.o
	ld -m elf_i386 -o kernel.bin -T link.ld kernel_entry.o kernel.o --oformat binary

# 编译内核入口汇编
# -f elf: 输出为 ELF 格式的目标文件 (Object File)，以便与 C 代码链接
kernel_entry.o: kernel_entry.asm
	nasm -f elf kernel_entry.asm -o kernel_entry.o

# 编译 C 内核
# -m32: 生成 32 位代码
# -ffreestanding: 独立环境 (无标准库，如 printf 等)
# -c: 只编译不链接
# -fno-pie: 禁用位置无关代码 (Position Independent Executable)，确保地址固定
kernel.o: kernel.c
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o -fno-pie

# 清理构建产物
clean:
	rm -f *.bin *.o

# 运行 QEMU 模拟器
run: os-image.bin
	qemu-system-x86_64 -drive format=raw,file=os-image.bin
