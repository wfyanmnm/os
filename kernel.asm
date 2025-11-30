; kernel.asm
; 注意：这里的 org 必须和 boot.asm 里定义的 KERNEL_OFFSET 一致
; 因为我们把代码加载到了内存 0x1000 处，所以所有的标号都基于这个地址
[org 0x1000]

main:
    ; 打印字符串证明我们要加载成功了
    mov si, success_msg
    call print_string

    jmp $ ; 内核死循环，停在这里

; --- 简单的打印字符串函数 ---
print_string:
    mov ah, 0x0e
.loop:
    lodsb       ; 加载 si 指向的字符到 al，并让 si + 1
    cmp al, 0   ; 字符串结尾是 0 吗？
    je .done
    int 0x10    ; 打印字符
    jmp .loop
.done:
    ret

success_msg: db 'Successfully landed in Kernel!', 0