all: program

program: helper.o jon_woods_caesar.o
	gcc -Wall -o program helper.o jon_woods_caesar.o

jon_woods_caesar.o: jon_woods_caesar.asm
	nasm -f elf64 jon_woods_caesar.asm

helper.o: helper.c
	gcc -c helper.c

clean:
	rm -f program jon_woods_caesar.o helper.o
