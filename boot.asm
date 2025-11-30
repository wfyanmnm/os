; boot.asm - 读取硬盘扇区演示
[org 0x7c00]

start:
    ; --- 1. 初始化 ---
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; [关键] BIOS 启动时会把启动盘的编号放在 DL 寄存器中
    ; 我们把它存到内存里备用，因为后面 DL 会被覆盖
    mov [BOOT_DRIVE], dl

    ; --- 2. 打印提示信息 ---
    mov si, msg_intro
    call print_string

    ; --- 3. 设置读取参数并调用 ---
    ; 目标：把硬盘第 2 个扇区读到内存地址 0x9000 处
    mov bx, 0x9000      ; ES:BX = 0x0000:0x9000 (目标地址)
    mov dh, 1           ; 读取 1 个扇区
    mov dl, [BOOT_DRIVE]; 驱动器号
    call disk_load

    ; --- 4. 验证是否成功 ---
    ; 如果读取成功，内存 0x9000 处应该就有数据了
    ; 我们把 si 指向 0x9000，看看能不能打印出那里面的字符串
    mov si, msg_success
    call print_string

    mov si, 0x9000      ; 指向我们要检查的内存地址
    call print_string   ; 打印刚刚读进来的内容！

    jmp $

; --- 磁盘读取函数 ---
; 参数：
;   DH = 要读取的扇区数量
;   DL = 驱动器号
;   ES:BX = 内存目标地址
disk_load:
    push dx             ; 保存 DX，因为我们后面要用它做比较

    mov ah, 0x02        ; BIOS 0x13 功能号 0x02：读取扇区
    mov al, dh          ; AL = 要读取的扇区数量
    mov ch, 0x00        ; 柱面 (Cylinder) 0
    mov dh, 0x00        ; 磁头 (Head) 0
    mov cl, 0x02        ; [注意] 扇区号从 1 开始。1 是 MBR，所以我们从 2 开始读

    int 0x13            ; --- 触发 BIOS 中断 ---

    jc disk_error       ; 如果 CF (Carry Flag) 为 1，说明出错了，跳转报错

    pop dx              ; 恢复 DX
    cmp dh, al          ; AL 会变成实际读取的扇区数。检查是否和预期(DH)一致
    jne disk_error      ; 如果不一致，也是出错了
    ret

disk_error:
    mov si, msg_error
    call print_string
    jmp $

; --- 打印函数 (老朋友) ---
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

; --- 数据区域 ---
BOOT_DRIVE: db 0
msg_intro:   db 'Reading disk...', 13, 10, 0
msg_error:   db 'Disk read error!', 0
msg_success: db 'Read success! Content: ', 0

; --- MBR 填充与签名 ---
times 510-($-$$) db 0
dw 0xaa55

; ======================================================
;        注意：这里已经是第 512 字节之后了！
;        这些数据位于硬盘的 "第 2 个扇区"
; ======================================================
times 256 db 'A'         ; 填充一些垃圾数据
db 'Hello from Sector 2!', 0  ; <--- 这就是我们要读取的宝藏
times 1024 - ($-$$) db 0     ; 填满第 2 个扇区