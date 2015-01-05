CC=gcc
ASMBIN=nasm

all : asm cc link
asm :
	$(ASMBIN) -o blend.o -f elf -l blend.lst blend.asm
cc :
	$(CC) -m32 -c -g -O0 main.c &> errors.txt
link :
	$(CC) -m32 -o test -lstdc++ main.o blend.o
clean :
	rm *.o
	rm test
	rm errors.txt
	rm blend.lst
