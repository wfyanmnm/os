; kernel.asm - 这是一个迷你内核
[org 0x9000]

start:
    ; --- 成功着陆！ ---
    ; 如果能运行到这里，说明 Bootloader 成功把我们加载并跳转过来了
    mov si, msg_kernel
    call print_string_kernel

    ; --- 内核主循环 ---
    jmp $

; --- 内核专用的打印函数 ---
; (注意：因为不在同一个文件了，它没法用 boot.asm 里的函数，必须自己带一个)
print_string_kernel:
    mov ah, 0x0e
.next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next
.done:
    ret

msg_kernel: db 'Success! I am the KERNEL code running at 0x9000!', 0