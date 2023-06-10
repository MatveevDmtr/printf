#include <stdio.h>

extern "C" void MyPrint(const char* str, ...);

int main()
    {
    char sym = 's';

    MyPrint("hihihaha %%%h, %x, %o, %b, %s, %c\n", 0xabcd, 5, 10, "printim strochku", sym);

    return 0;
    }