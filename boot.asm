; boot.asm - 加载器
[org 0x7c00]

KERNEL_OFFSET equ 0x9000 ; 定义一个常量，方便以后改

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    
    mov [BOOT_DRIVE], dl ; 保存盘号

    ; --- 1. 打印提示 ---
    mov si, msg_load
    call print_string

    ; --- 2. 读取内核 ---
    mov bx, KERNEL_OFFSET ; 读取目标地址: 0x9000
    mov dh, 1             ; 读取 1 个扇区
    mov dl, [BOOT_DRIVE]
    call disk_load

    ; --- 3. 关键时刻：移交控制权！ ---
    mov si, msg_jump
    call print_string

    jmp KERNEL_OFFSET     ; <--- 信仰之跃！跳到 0x9000 去执行代码

    jmp $ ; 这一行永远不会被执行

; --- 磁盘读取函数 (保持不变) ---
disk_load:
    push dx
    mov ah, 0x02
    mov al, dh
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02
    int 0x13
    jc disk_error
    pop dx
    cmp dh, al
    jne disk_error
    ret

disk_error:
    mov si, msg_error
    call print_string
    jmp $

; --- 打印函数 (保持不变) ---
print_string:
    mov ah, 0x0e
.next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next
.done:
    ret

; --- 数据 ---
BOOT_DRIVE: db 0
msg_load:   db 'Loading Kernel...', 13, 10, 0
msg_error:  db 'Disk Error!', 0
msg_jump:   db 'Jumping to Kernel...', 13, 10, 0

; --- MBR 结尾 ---
times 510-($-$$) db 0
dw 0xaa55