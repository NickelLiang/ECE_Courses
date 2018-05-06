CC=gcc
CFLAGS=-g -std=c99 -Werror #-Wall

all:
	$(CC) $(CFLAGS) graph.c main.c dijkstra.c bellmanford.c -o hlab7

error:
	$(CC) $(CFLAGS) -Wall graph.c main.c dijkstra.c bellmanford.c -o hlab7

run:
	./hlab7 Peoria Champaign o

run-nc:
	./hlab7 Peoria Champaign w

clean:
	rm hlab7
