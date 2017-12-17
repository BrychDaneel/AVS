.PHONY: all
all: lab1.com

lab1.com: lab1.o
	ld -T ldscrpt --oformat binary lab1.o -o lab1.com

lab1.o: lab1.s
	as -march=i386 --32  lab1.S -o lab1.o
