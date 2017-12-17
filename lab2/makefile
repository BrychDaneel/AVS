.PHONY: all
all: lab2.com

lab2.com: lab2.o
	ld -T ldscrpt --oformat binary lab2.o -o lab2.com

lab2.o: lab2.s
	as -march=i386 --32  lab2.S -o lab2.o
