.PHONY : all
all: lab3 lab3_nomp

lab3: main.o
	gcc main.o -fopenmp -o lab3

main.o: main.c
	gcc main.c -c -fopenmp -o main.o
