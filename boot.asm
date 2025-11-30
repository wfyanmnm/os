; boot.asm - 改进版：使用循环打印字符串
[org 0x7c00]

start:
    ; --- 1. 初始化段寄存器 (保持不变) ---
    xor ax, ax      ; 将 ax 清零
    mov ds, ax      ; 数据段 ds = 0
    mov es, ax      ; 附加段 es = 0
    mov ss, ax      ; 栈段 ss = 0
    mov sp, 0x7c00  ; 栈指针

    ; --- 2. 准备打印 ---
    ; 将 si 寄存器指向我们要打印的字符串地址
    mov si, msg
    call print_string

    ; --- 3. 无限循环 (CPU 挂起) ---
    jmp $

; --- 函数：打印字符串 ---
; 输入：si = 字符串首地址
print_string:
    mov ah, 0x0e        ; BIOS Teletype 输出模式

.next_char:
    lodsb               ; 关键指令：将 [si] 读取到 al，并且自动 si = si + 1
    cmp al, 0           ; 检查 al 是否为 0 (字符串结束符)
    je .done            ; 如果是 0，跳转到 .done 结束
    int 0x10            ; 否则，调用 BIOS 打印 al 中的字符
    jmp .next_char      ; 循环，处理下一个字符

.done:
    ret                 ; 返回主程序

; --- 数据区域 ---
; db 定义字节, 0 是结束符 (类似 C 语言的 '\0')
; 13 是回车(CR), 10 是换行(LF)
msg: db 'Hello, Arch Linux OS!', 13, 10, 0 

; --- 填充与魔数 (保持不变) ---
times 510-($-$$) db 0
dw 0xaa55