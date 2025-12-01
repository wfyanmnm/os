; GDT (Global Descriptor Table) 全局描述符表
gdt_start:

gdt_null: ; 必须的空描述符 (Null Descriptor)
    dd 0x0 ; 'dd' 定义双字 (4字节)
    dd 0x0 ; 空描述符共 8 字节，全为 0

gdt_code: ; 代码段描述符 (Code Segment Descriptor)
    ; 基地址 (Base) = 0x0, 段界限 (Limit) = 0xfffff
    ; 1st flags: (present)1 (privilege)00 (descriptor type)1 -> 1001b
    ; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 -> 1010b
    ; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 -> 1100b
    dw 0xffff    ; 段界限 (Limit) (位 0-15)
    dw 0x0       ; 基地址 (Base) (位 0-15)
    db 0x0       ; 基地址 (Base) (位 16-23)
    db 10011010b ; 1st flags, type flags (访问权限等)
    db 11001111b ; 2nd flags, Limit (位 16-19)
    db 0x0       ; 基地址 (Base) (位 24-31)

gdt_data: ; 数据段描述符 (Data Segment Descriptor)
    ; 与代码段类似，除了 type flags 不同:
    ; type flags: (code)0 (expand down)0 (writable)1 (accessed)0 -> 0010b
    dw 0xffff    ; 段界限 (Limit) (位 0-15)
    dw 0x0       ; 基地址 (Base) (位 0-15)
    db 0x0       ; 基地址 (Base) (位 16-23)
    db 10010010b ; 1st flags, type flags
    db 11001111b ; 2nd flags, Limit (位 16-19)
    db 0x0       ; 基地址 (Base) (位 24-31)

gdt_end: ; 这里的标签用于计算 GDT 的大小
         ; 汇编器会利用这个标签减去 gdt_start 来得到总长度

; GDT 描述符 (GDT Descriptor)
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; GDT 的大小 (Size)，总是比真实大小少 1
    dd gdt_start               ; GDT 的起始地址 (Start Address)

; 定义一些常量，表示 GDT 段描述符的偏移量 (Offsets)
; 这些偏移量是我们在保护模式下设置段寄存器时需要使用的值。
; 例如，当我们将 DS 设置为 0x10 时，CPU 就知道我们要使用 GDT 中偏移量为 0x10 (16字节) 的那个段描述符。
; 在我们的 GDT 中:
; 0x00 -> NULL (空描述符)
; 0x08 -> CODE (代码段)
; 0x10 -> DATA (数据段)
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
