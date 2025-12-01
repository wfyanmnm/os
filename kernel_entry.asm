; kernel_entry.asm
[bits 32] ; 确保我们处于 32 位保护模式
[extern main] ; 声明外部符号 'main'，这是我们在 C 代码中定义的函数
              ; 链接器 (Linker) 会在链接时找到它的地址

call main ; 调用 C 语言的 main 函数
          ; 此时控制权从汇编转移到了 C 语言

jmp $ ; 如果 main 函数返回了 (虽然在操作系统中通常不会返回)，
      ; 我们进入死循环，防止 CPU 执行后续内存中的垃圾数据
