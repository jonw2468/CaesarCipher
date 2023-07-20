all: program

program: helper.o caesar.o
	gcc -Wall -o program helper.o caesar.o

caesar.o: caesar.asm
	nasm -f elf64 caesar.asm

helper.o: helper.c
	gcc -c helper.c

clean:
	rm -f program caesar.o helper.o
