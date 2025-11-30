#define VIDEO_MEMORY 0xb8000
#define WHITE_ON_BLACK 0x0f

// Screen dimensions
#define MAX_ROWS 25
#define MAX_COLS 80

// Global cursor position
int cursor_offset = 0;

// Helper function to set cursor position (optional, for now just internal tracking)
// For a real driver we'd use ports to move the hardware cursor too.

void clear_screen() {
    char* screen = (char*) VIDEO_MEMORY;
    for (int i = 0; i < MAX_ROWS * MAX_COLS; i++) {
        screen[i * 2] = ' ';
        screen[i * 2 + 1] = WHITE_ON_BLACK;
    }
    cursor_offset = 0;
}

void print_string(char* message) {
    char* screen = (char*) VIDEO_MEMORY;
    int i = 0;
    while (message[i] != 0) {
        char c = message[i];
        
        if (c == '\n') {
            // Calculate current row
            int row = cursor_offset / (2 * MAX_COLS);
            // Move to start of next row
            cursor_offset = (row + 1) * (2 * MAX_COLS);
        } else {
            screen[cursor_offset] = c;
            screen[cursor_offset + 1] = WHITE_ON_BLACK;
            cursor_offset += 2;
        }
        i++;
    }
}

void main() {
    clear_screen();
    print_string("Hello, OS World!\n");
    print_string("Welcome to the C Kernel.\n");
    print_string("We now have a basic screen driver!");
}
