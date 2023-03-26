#include <stdio.h>

extern "C" void MyPrint(const char* str, ...);

int main()
    {
    MyPrint("hihihaha");

    printf ("main()");

    printf ("\n" "main(): end\n\n");
    return 0;
    }