#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>
#include <limits.h>

typedef enum {UNVISITED, VISITED, UNCHECKED, CHECKED} flag_t;

typedef struct node {
    char name[50];
    float x,y;
    struct edge *edges;
    flag_t flag; // To be used in checkpoint2 algorithms
} NODE;

typedef struct edge {
    float distance;
    struct node *node;
    struct edge *next;
} EDGE;

NODE *nodes;
int nodeCount;

void readNodeFile(char *);
int addNode(char *, float, float);
int addEdge(char *src, char *dest, float weight);
void readEdgeFile(char *input_filename);
void dijkstra(char *src, char *destn);
void bellmanford(char *src, char *destn);
