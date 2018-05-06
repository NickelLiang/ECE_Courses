#include "graph.h"
int main(int argc, char *argv[]) {
    if (argv[3][0] != 'w') {
        printf("Run without Negative Cycle:\n");
        readNodeFile("nodes.txt");
        readEdgeFile("edges.txt");
        // dijkstra(argv[1], argv[2]);
        bellmanford(argv[1], argv[2]);
    } else {
        printf("Run with Negative Cycle:\n");
        readNodeFile("nodes.txt");
        readEdgeFile("edgesnc.txt");
        // dijkstra(argv[1], argv[2]);
        bellmanford(argv[1], argv[2]);
    }

}
