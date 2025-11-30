; boot.asm - 一个极简的 Bootloader
; 告诉编译器这段代码将被加载到内存 0x7c00 处
[org 0x7c00]

start:
    ; --- 初始化段寄存器 ---
    xor ax, ax      ; 将 ax 清零
    mov ds, ax      ; 数据段 ds = 0
    mov es, ax      ; 附加段 es = 0
    mov ss, ax      ; 栈段 ss = 0
    mov sp, 0x7c00  ; 栈指针指向 0x7c00 下方（避免覆盖代码）

    ; --- 打印字符 ---
    ; 利用 BIOS 中断 0x10 来打印字符
    ; AH = 0x0E (Teletype output 模式)
    mov ah, 0x0e 

    mov al, 'H'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'l'
    int 0x10
    mov al, 'l'
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, ','
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 'O'
    int 0x10
    mov al, 'S'
    int 0x10

    ; --- 无限循环 ---
    ; 操作系统不能退出，必须一直运行，所以这里用死循环挂起 CPU
    jmp $

; --- 填充与魔数 ---
; MBR 必须正好是 512 字节
; times 计算需要填充多少个 0
; $ 代表当前地址，$$ 代表段起始地址
times 510-($-$$) db 0

; 最后两个字节必须是 0x55, 0xaa (小端序写为 0xaa55)
dw 0xaa55
