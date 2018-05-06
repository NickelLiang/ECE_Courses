#include "graph.h"

void dijkstra(char *src, char *destn) {
    float *dist = (float *)malloc(sizeof(float)*nodeCount);
    int *prev   = (int *)malloc(sizeof(int)*nodeCount);
    int *path   = (int *)malloc(sizeof(int)*nodeCount);
    int i, j, source, dest;
    // Find source
    for (i=0;i<nodeCount;i++) {
        if(strcmp(src,(nodes+i)->name)==0)
            break;
    }
    source = i;
    // Find destination
    for (i = 0; i < nodeCount; i++) {
        if(strcmp(destn,(nodes+i)->name)==0)
            break;
    }
    dest = i;

    // initializing distance matrix to be infinity
	// and prev array to infinity
    for (i = 0; i < nodeCount; i++) {
        *(dist+i) = INT_MAX;
		*(prev+i) = INT_MAX;
    }
    *(dist + source) = 0; // setting source distance to zero
    // initializing nodes to be unvisited
    for (i = 0; i < nodeCount; i++) {
        (nodes+i)->flag = UNVISITED;
    }

    NODE *current = nodes + source; // We are at the source
	current->flag = VISITED; // Source is visited
    while ((nodes+dest)->flag == UNVISITED) { // While we haven't reach to the destination
        EDGE *head = current->edges; // The first edge of the current node
        while (head != NULL) { // Go over all the edges
			if (head->node->flag == VISITED) { // If the node is visited
				head = head->next;
				continue; // We ignore it
			}
            j = (head->node - nodes); // Find the place of the other node in the array
            if(dist[j] > (dist[current-nodes] + head->distance)) { // If distance is smaller than current value
                dist[j] = dist[current-nodes] + head->distance; // Update distance to shorter one
                prev[j] = current-nodes; // prev list point to shortest distance origin
            }
            head = head->next; // Check next edge
        }
		current->flag = VISITED; // Update current flag
        for (j = 0; j < nodeCount; j++) { // If there's still unvisited node, break
            if ((nodes+j)->flag == UNVISITED && dist[j] != INT_MAX)
                break;
        }
		if (j == nodeCount) { // If no more nodes unvisited, return
			printf("No path between source and destination\n");
			return;
		}
        for (i = 0; i < nodeCount; i++) {
            if (dist[i] != INT_MAX && dist[i] < dist[j] && (nodes+i)->flag == UNVISITED)
                j = i; // Find the node with smalllest distance
        }
        current = nodes + j; // update current
    }

    int previous = dest;
    path[0] = previous; // The first item in path is destination
    i = 1;
    while (previous != source) { // Go back to source
        previous = prev[previous];
        path[i] = previous;
        i++;
    }
    path[i] = source;
	i--;

    for( ; i >= 0; --i) {
        printf("%s ", (nodes+path[i])->name);
    }
	printf("\n");
    //
    // printf("dist | prev | path\n");
    // for (i = 0; i < nodeCount; i++) {
    //     printf("%f \t", dist[i]);
    //     printf("%d \t", prev[i]);
    //     printf("%d \t", path[i]);
    //     printf("\n");
    // }

    //
    // printf("prev\n");
    // for (i = 0; i < nodeCount; i++) {
    //     printf("%d ", prev[i]);
    // }
    // printf("\n");
    //
    // printf("path\n");
    // for (i = 0; i < nodeCount; i++) {
    //     printf("%d ", path[i]);
    // }
    // printf("\n");
}