[bits 16] ; 告诉汇编器，以下代码是 16 位的
switch_to_pm:
    cli ; 1. 禁用中断 (Disable Interrupts)
        ; 在切换模式期间，必须关闭中断，防止 CPU 处理中断时发生混乱
        ; 直到我们在保护模式下重新设置好中断向量表 (IDT) 之前，都不能开启中断

    lgdt [gdt_descriptor] ; 2. 加载 GDT 描述符 (Load GDT)
                          ; 将 GDT 的大小和地址加载到 GDTR 寄存器中

    mov eax, cr0
    or eax, 0x1
    mov cr0, eax ; 3. 设置 CR0 寄存器的最低位 (PE 位) 为 1
                 ; 这标志着 CPU 正式进入保护模式 (Protected Mode)

    jmp CODE_SEG:init_pm ; 4. 执行远跳转 (Far Jump)
                         ; 这一步非常关键：
                         ; 1. 它强制 CPU 刷新流水线 (Pipeline Flush)，因为 16 位和 32 位指令解码不同
                         ; 2. 它更新 CS 寄存器为 CODE_SEG (0x08)，指向 GDT 中的代码段

[bits 32] ; 告诉汇编器，以下代码是 32 位的
init_pm:
    mov ax, DATA_SEG ; 5. 更新段寄存器
    mov ds, ax       ; 将所有数据段寄存器 (DS, SS, ES, FS, GS) 指向 GDT 中的数据段 (0x10)
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 ; 6. 设置栈顶指针
    mov esp, ebp     ; 将栈设置在空闲内存的高地址处 (0x90000)

    call BEGIN_PM ; 7. 调用保护模式下的主逻辑
                  ; 跳转到 boot.asm 中定义的 BEGIN_PM 标签

