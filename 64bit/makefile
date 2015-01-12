CC=gcc
ASMBIN=nasm

all : asm cc link
asm :
	$(ASMBIN) -o blend.o -f elf64 -l blend.lst blend.asm
cc :
	$(CC) -c -g -O0 main.c
link :
	$(CC) -o test -lstdc++ -lX11 main.o blend.o
clean :
	rm *.o
	rm test
	rm blend.lst
