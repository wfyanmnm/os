; 16 位实模式下的字符串打印函数
; 参数:
;   si: 指向以 0 结尾的字符串的起始地址
print_string:
    pusha           ; 保存所有通用寄存器 (ax, cx, dx, bx, sp, bp, si, di)

    mov ah, 0x0e    ; BIOS int 0x10 功能号: 0x0e = 电传打字机输出 (Teletype output)
                    ; 这个功能会在光标处打印字符并自动移动光标

.loop:
    lodsb           ; 从 [si] 加载一个字节到 al，并自动增加 si
    cmp al, 0       ; 检查是否是字符串结束符 (0)
    je .done        ; 如果是 0，跳转到结束

    int 0x10        ; 调用 BIOS 中断，打印 al 中的字符
    jmp .loop       ; 继续循环，处理下一个字符

.done:
    popa            ; 恢复所有通用寄存器
    ret             ; 返回调用处

; 32 位保护模式下的字符串打印函数
; 注意：在保护模式下不能使用 BIOS 中断，必须直接写显存
; 参数:
;   ebx: 指向以 0 结尾的字符串的起始地址
print_string_pm:
    pusha           ; 保存所有 32 位寄存器
    mov edx, VIDEO_MEMORY ; 将显存起始地址加载到 edx

.loop:
    mov al, [ebx]   ; 从 [ebx] 加载一个字符到 al
    mov ah, WHITE_ON_BLACK ; 设置属性字节 (黑底白字)

    cmp al, 0       ; 检查是否是字符串结束符
    je .done        ; 如果是 0，结束

    mov [edx], ax   ; 将字符+属性 (2字节) 写入显存当前位置
    add ebx, 1      ; 移动字符串指针到下一个字符
    add edx, 2      ; 移动显存指针到下一个字符位置 (每个字符占 2 字节)

    jmp .loop       ; 继续循环

.done:
    popa            ; 恢复寄存器
    ret             ; 返回

VIDEO_MEMORY equ 0xb8000 ; VGA 文本模式显存的物理起始地址
WHITE_ON_BLACK equ 0x0f  ; 属性字节: 黑色背景(0) + 白色前景(f)
