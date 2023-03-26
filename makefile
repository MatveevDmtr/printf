all: assembly link run

assembly: printf_v1.asm
	nasm -f elf64 -l printf.lst printf_v1.asm

link: printf_v1.o
	ld -s -o printf_v1 printf_v1.o

run: printf_v1
	./printf_v1