#include <stdio.h>

extern "C" void MyPrint(const char* str, ...);

int main()
    {
    char sym = 's';

    MyPrint("test: %%, %x, %o, %b, %s, %c\n", 0xabcd, 5, 10, "testline", sym);

    return 0;
    }