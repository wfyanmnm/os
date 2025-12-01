#define VIDEO_MEMORY 0xb8000 // VGA 文本模式显存的物理起始地址
#define WHITE_ON_BLACK 0x0f  // 属性字节：黑底白字

// 屏幕尺寸常量
#define MAX_ROWS 25
#define MAX_COLS 80

// 全局光标位置变量 (偏移量)
// 记录当前光标在显存中的位置 (以字节为单位)
int cursor_offset = 0;

// 清屏函数
// 遍历整个显存，将所有字符设置为空格，属性设置为黑底白字
void clear_screen() {
    char* screen = (char*) VIDEO_MEMORY; // 将显存地址强制转换为字符指针
    for (int i = 0; i < MAX_ROWS * MAX_COLS; i++) {
        screen[i * 2] = ' ';       // 字符字节：空格
        screen[i * 2 + 1] = WHITE_ON_BLACK; // 属性字节
    }
    cursor_offset = 0; // 重置光标位置到左上角
}

// 打印字符串函数
// 参数: message - 要打印的字符串指针
void print_string(char* message) {
    char* screen = (char*) VIDEO_MEMORY;
    int i = 0;
    while (message[i] != 0) { // 遍历字符串直到遇到结束符 '\0'
        char c = message[i];
        
        if (c == '\n') { // 处理换行符
            // 计算当前行号
            int row = cursor_offset / (2 * MAX_COLS);
            // 将光标移动到下一行的起始位置
            cursor_offset = (row + 1) * (2 * MAX_COLS);
        } else { // 普通字符
            screen[cursor_offset] = c;          // 写入字符
            screen[cursor_offset + 1] = WHITE_ON_BLACK; // 写入属性
            cursor_offset += 2;                 // 移动光标到下一个字符位置 (2字节)
        }
        i++; // 处理下一个字符
    }
}

// 内核入口函数
void main() {
    clear_screen(); // 首先清空屏幕
    print_string("Hello, OS World!\n");
    print_string("Welcome to the C Kernel.\n");
    print_string("We now have a basic screen driver!");
}
