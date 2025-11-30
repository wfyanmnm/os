[org 0x7c00]
    KERNEL_OFFSET equ 0x1000

    mov [BOOT_DRIVE], dl

    mov bp, 0x9000 ; Stack base
    mov sp, bp

    mov si, msg_real_mode
    call print_string

    call load_kernel

    call switch_to_pm

    jmp $

%include "print_string.asm"
%include "disk_load.asm"
%include "gdt.asm"
%include "switch_to_pm.asm"

[bits 16]
load_kernel:
    mov si, msg_load_kernel
    call print_string

    mov bx, KERNEL_OFFSET
    mov dh, 15
    mov dl, [BOOT_DRIVE]
    call disk_load

    ret

[bits 32]
BEGIN_PM:
    ; mov ebx, msg_prot_mode
    ; call print_string_pm

    call KERNEL_OFFSET

    jmp $

BOOT_DRIVE: db 0
msg_real_mode: db "Started in 16-bit Real Mode", 0
msg_load_kernel: db "Loading kernel into memory.", 0
msg_prot_mode: db "Successfully landed in 32-bit Protected Mode", 0

times 510-($-$$) db 0
dw 0xaa55