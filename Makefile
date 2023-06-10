all: assembly compile_c link_c_asm run_c clear

assembly: src/printf.asm
	nasm -f elf64 -l printf.lst src/printf.asm

compile_c:
	g++ -c src/printf_c.cpp printf_c.o
link_c_asm: src/printf.o printf_c.o
	g++ printf_c.o -no-pie src/printf.o -o printf
run_c:
	./printf
clear:
	rm *.o
	rm src/*.o