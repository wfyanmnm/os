; 加载磁盘扇区到内存的函数
; 参数:
;   dh: 需要读取的扇区数量
;   dl: 驱动器号 (由 BIOS 传入)
;   es:bx: 数据存储的目标内存地址 (调用前设置)
disk_load:
    push dx         ; 保存 dx 寄存器的值到栈中，因为后面 int 0x13 会修改它
                    ; 我们稍后需要用原始的 dh (想读的数量) 来做校验

    mov ah, 0x02    ; BIOS int 0x13 功能号: 0x02 = 读取扇区
    mov al, dh      ; 读取数量: 将参数 dh (想读多少个) 赋值给 al
    mov ch, 0x00    ; 柱面号 (Cylinder): 0x00 (第 0 柱面)
    mov dh, 0x00    ; 磁头号 (Head): 0x00 (第 0 磁头)
    mov cl, 0x02    ; 起始扇区号 (Sector): 0x02 (第 2 个扇区)
                    ; 注意: 扇区从 1 开始计数。第 1 个扇区是引导扇区本身，
                    ; 所以我们的内核代码是从第 2 个扇区开始的。

    int 0x13        ; 调用 BIOS 中断，执行磁盘读取操作

    jc disk_error   ; 检查 Carry Flag (CF)。如果置位 (CF=1)，说明读取出错，跳转到错误处理

    pop dx          ; 恢复最开始保存的 dx 寄存器 (找回原始的 dh)
    cmp dh, al      ; 比较: 想要读取的扇区数 (dh) vs 实际读取到的扇区数 (al)
    jne disk_error  ; 如果不相等 (Jump if Not Equal)，说明读取不完整，跳转到错误处理

    ret             ; 读取成功，返回调用处

disk_error:
    mov si, msg_disk_error ; 将错误信息的地址加载到 si
    call print_string      ; 调用打印字符串函数
    jmp $                  ; 死循环，挂起系统，防止执行未知代码

msg_disk_error: db "Disk read error!", 0
