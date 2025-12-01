[org 0x7c00] ; 告诉汇编器，这段代码将被加载到内存地址 0x7c00 处
    KERNEL_OFFSET equ 0x1000 ; 定义内核加载的目标内存地址常量

    mov [BOOT_DRIVE], dl ; BIOS 启动时会将启动盘号存储在 dl 寄存器中，我们需要保存它

    mov bp, 0x9000 ; 设置栈底指针 (Base Pointer) 到 0x9000
    mov sp, bp     ; 设置栈顶指针 (Stack Pointer) 也到 0x9000，栈向低地址增长

    mov si, msg_real_mode ; 将实模式下的欢迎信息地址加载到 si
    call print_string     ; 调用打印函数

    call load_kernel ; 调用加载内核的子程序

    call switch_to_pm ; 调用切换到保护模式的子程序
                      ; 注意：这个调用不会返回，因为 switch_to_pm 会跳转到 32 位代码

    jmp $ ; 死循环，防止代码跑飞 (理论上不会执行到这里)

%include "print_string.asm" ; 包含字符串打印函数
%include "disk_load.asm"    ; 包含磁盘加载函数
%include "gdt.asm"          ; 包含全局描述符表 (GDT) 定义
%include "switch_to_pm.asm" ; 包含切换保护模式的代码

[bits 16] ; 显式指定以下代码为 16 位模式
load_kernel:
    mov si, msg_load_kernel ; 打印 "Loading kernel" 信息
    call print_string

    mov bx, KERNEL_OFFSET ; 设置磁盘读取的目标内存地址 (es:bx)
    mov dh, 15            ; 设置要读取的扇区数量 (读取 15 个扇区，确保包含整个内核)
    mov dl, [BOOT_DRIVE]  ; 从变量中取出之前保存的驱动器号
    call disk_load        ; 调用磁盘读取函数

    ret

[bits 32] ; 显式指定以下代码为 32 位模式
BEGIN_PM: ; 保护模式的入口标签 (在 switch_to_pm.asm 中跳转过来)
    ; mov ebx, msg_prot_mode ; (可选) 打印保护模式下的欢迎信息
    ; call print_string_pm

    call KERNEL_OFFSET ; 跳转到内核代码的入口地址 (0x1000)
                       ; 这将把控制权移交给 kernel_entry.asm

    jmp $ ; 死循环，停在这里

BOOT_DRIVE: db 0 ; 用于存储驱动器号的变量
msg_real_mode: db "Started in 16-bit Real Mode", 0
msg_load_kernel: db "Loading kernel into memory.", 0
msg_prot_mode: db "Successfully landed in 32-bit Protected Mode", 0

times 510-($-$$) db 0 ; 填充剩余空间为 0，直到 510 字节
dw 0xaa55             ; 引导扇区的结束标志 (魔数)