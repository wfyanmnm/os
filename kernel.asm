; kernel.asm - 32-bit Kernel
[org 0x9000]
[bits 32]

start:
    ; Print a message to video memory
    mov esi, msg_kernel
    mov edi, 0xb8000 ; Video memory address

print_loop:
    mov al, [esi]
    cmp al, 0
    je done

    mov [edi], al     ; Character
    mov byte [edi+1], 0x0f ; Attribute (White on Black)

    add esi, 1
    add edi, 2
    jmp print_loop

done:
    jmp $

msg_kernel: db "Success! Kernel is running in 32-bit Protected Mode!", 0