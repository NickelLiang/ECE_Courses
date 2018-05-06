#include "graph.h"

void bellmanford(char *src, char *destn) {
    // Step 1: Initialize
    float *dist = (float *)malloc(sizeof(float)*nodeCount);
    int *prev   = (int *)  malloc(sizeof(int)*nodeCount);
    int *path   = (int *)  malloc(sizeof(int)*nodeCount);
    int i, j, source, dest;
    // Find source
    for (i=0;i<nodeCount;i++) {
        if (strcmp(src,(nodes+i)->name) == 0)
            break;
    }
    source = i;
    // Find destination
    for (i = 0; i < nodeCount; i++) {
        if (strcmp(destn,(nodes+i)->name) == 0)
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

    // Step 2: Relax edges repeatedly
    NODE *current = nodes + source; // We are at the source
	current->flag = VISITED; // Source is visited
    while ((nodes+dest)->flag == UNVISITED) { // While we haven't reach to the destination
        // printf("%s\n", current->name);
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

    // printf("dist \t");
    // for (i = 0; i < nodeCount; i++) {
    //     printf("%f ", dist[i]);
    // }
    // printf("\n");

    // Step 3: Detect negative cycles
    // printf("\nStep3\n" );
    float *dist2 = (float *)malloc(sizeof(float)*nodeCount);
    for (i = 0; i < nodeCount; i++) {
        *(dist2+i) = dist[i];
    }
    // *(dist2 + source) = 0; // setting source distance to zero
    // printf("dist2 \t");
    // for (i = 0; i < nodeCount; i++) {
    //     printf("%f ", dist2[i]);
    // }
    // printf("\n");



    for (i = 0; i < nodeCount; i++) {
        (nodes+i)->flag = UNVISITED;
    }
    current = nodes + source; // We are at the source
	current->flag = VISITED; // Source is visited
    while ((nodes+dest)->flag == UNVISITED) { // While we haven't reach to the destination
        // printf("%s\n", current->name);
        EDGE *head = current->edges; // The first edge of the current node
        while (head != NULL) { // Go over all the edges
			// if (head->node->flag == VISITED) { // If the node is visited
			// 	head = head->next;
			// 	continue; // We ignore it
			// }
            j = (head->node - nodes); // Find the place of the other node in the array
            if(dist2[j] > (dist2[current-nodes] + head->distance)) { // If distance is smaller than current value
                // printf("fuck\n");
                // printf("%s dist[j] %f dis[i]+d %f dis[i] %f\n", current->name, dist[j], dist[current-nodes] + head->distance, dist[current-nodes]);
                dist2[j] = dist2[current-nodes] + head->distance; // Update distance to shorter one
                // prev[j] = current-nodes; // prev list point to shortest distance origin
            }
            head = head->next; // Check next edge
        }
		current->flag = VISITED; // Update current flag

        for (j = 0; j < nodeCount; j++) { // If there's still unvisited node, break
            if ((nodes+j)->flag == UNVISITED && dist2[j] != INT_MAX)
                break;
        }

        for (i = 0; i < nodeCount; i++) {
            if (dist2[i] != INT_MAX && dist2[i] < dist2[j] && (nodes+i)->flag == UNVISITED)
                j = i; // Find the node with smalllest distance
        }
        current = nodes + j; // update current
    }

    // printf("dist2a\t");
    // for (i = 0; i < nodeCount; i++) {
    //     printf("%f ", dist2[i]);
    // }
    // printf("\n");


    for (i = 0; i < nodeCount; i++) {
        if (dist[i] != dist2[i]) {
            printf("Graph contains a negative weight cycle\n");
            return;
        }
    }

    // Step 4: Print result
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
}
