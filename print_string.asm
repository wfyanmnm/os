print_string:
    pusha
    mov ah, 0x0e
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY
.loop:
    mov al, [ebx]
    mov ah, WHITE_ON_BLACK

    cmp al, 0
    je .done

    mov [edx], ax
    add ebx, 1
    add edx, 2

    jmp .loop
.done:
    popa
    ret

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f
