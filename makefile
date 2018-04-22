all: main

main: asm.o
	gcc -g -Wall -o root asm.o

asm.o: asm.s
	nasm -g -f elf64 -w+all -o asm.o asm.s

.PHONY: clean

clean: 
	rm -f *.o root
