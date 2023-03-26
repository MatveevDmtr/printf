all: assembly compile_c link_c_asm run_c

assembly: printf_v1.asm
	nasm -f elf64 -l printf.lst printf_v1.asm

compile_c:
	g++ -c printf_c.cpp printf_c.o
link_c_asm: printf_v1.o printf_c.o
	g++ printf_c.o -no-pie printf_v1.o -o printf
run_c:
	./printf