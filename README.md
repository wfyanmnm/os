# 安装工具
安装工具, 在 Arch Linux 终端中，你需要安装汇编器 nasm 和模拟器 qemu
```
sudo pacman -S nasm qemu-full
```

# 引导
编译汇编代码： 将 .asm 编译成纯二进制文件（Bin）
```
nasm -f bin boot.asm -o boot.bin
```

启动虚拟机
```
qemu-system-x86_64 boot.bin
```

# 加载kernel
```
nasm -f bin boot2.asm -o boot2.bin
nasm -f bin kernel.asm -o kernel.bin
cat boot2.bin kernel.bin > os-image.bin
qemu-system-x86_64 os-image.bin
```