[org 0x7c00]

; 定义一个常量，表示我们将要把内核加载到内存的哪个位置
KERNEL_OFFSET equ 0x1000 

    ; --- 1. 初始化 ---
    mov [BOOT_DRIVE], dl ; BIOS 启动时会将启动盘号存在 dl 中，我们需要保存它
                         ; 因为后续操作可能会覆盖 dl

    mov bp, 0x9000       ; 设置栈底，选一个安全的远处
    mov sp, bp

    call load_kernel     ; 调用读取磁盘函数
    call switch_to_kernel ; 跳转函数

    jmp $                ;以此防止意外

; --- 2. 读取磁盘子程序 ---
load_kernel:
    mov bx, KERNEL_OFFSET ; bx 是读取数据的缓冲区地址 (ES:BX)
    mov dh, 1             ; 读取 1 个扇区 (我们的 kernel 目前很小)
    mov dl, [BOOT_DRIVE]  ; 驱动器号
    
    ; 调用 int 0x13, AH=0x02 (读取扇区)
    mov ah, 0x02
    mov al, dh    ; 读取扇区数量
    mov ch, 0x00  ; 柱面 (Cylinder) 0
    mov dh, 0x00  ; 磁头 (Head) 0
    mov cl, 0x02  ; 起始扇区 (Sector) 2 
                  ; 注意：扇区是从 1 开始计数的，1 是 MBR，所以内核在 2
    
    int 0x13      ; 触发 BIOS 中断读取磁盘
    
    jc disk_error ; 如果出错，进位标志(Carry Flag)会被置位，跳转报错
    ret

disk_error:
    mov ah, 0x0e
    mov al, 'E'   ; Error
    int 0x10
    jmp $

; --- 3. 跳转子程序 ---
switch_to_kernel:
    mov ah, 0x0e
    mov al, 'J'   ; 打印 'J' 表示即将 Jump
    int 0x10
    
    jmp KERNEL_OFFSET ; 关键一跳！飞向我们的内核代码

; --- 变量 ---
BOOT_DRIVE: db 0

; --- MBR 填充 ---
times 510-($-$$) db 0
dw 0xaa55