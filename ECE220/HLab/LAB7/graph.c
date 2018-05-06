#include "graph.h"

int addNode(char *name, float x, float y) {
    NODE *temp_node=nodes;
    int i;
    for(i=0;i<nodeCount;i++) {
        // if node already exists return
        if(strcmp((temp_node+i)->name,name)==0)
            return -1;
    }
    temp_node = (NODE *) realloc(nodes, (nodeCount+1) * sizeof(NODE));
    if(temp_node) {
        if(temp_node - nodes) { //if the memory has been moved to a new block then node - nodes will be non-zero or true
            int j= temp_node - nodes;
            for(i=0;i<nodeCount;i++) {
                if((temp_node+i)->edges) {
                    EDGE *temp;
                    temp=(temp_node+i)->edges;
                    while(temp!=NULL) {
                        temp->node=temp->node + j;
                        temp=temp->next;
                    }
                }
            }
        }
        nodes=temp_node;
        strcpy((nodes+nodeCount)->name, name);
        (nodes+nodeCount)->x = x;
        (nodes+nodeCount)->y = y;
        (nodes+nodeCount)->edges = NULL;
        nodeCount++;
        return 0;
    }
    // if malloc fails
    return -1;
}

// Read input file, save as a node struct
void readNodeFile(char *input_filename) {
    char name[50];
    float x, y;

    FILE *input;
    if (!(input = fopen(input_filename, "r"))) {
        fprintf(stderr, "Unable to open input file\n");
        return;
    }

    while(fscanf(input, "%s %f %f", name, &x, &y) == 3) {
        addNode(name, x, y);
    }
    fclose(input);
}

int addEdge(char *name1, char *name2, float weight) {
    NODE *node1, *node2;
    node1=nodes;
    node2=nodes;
    while(strcmp(node1->name,name1) != 0)
        node1++;
    while(strcmp(node2->name,name2) != 0)
        node2++;

    if(node1->edges) {
        EDGE *edge_temp;
        edge_temp=node1->edges;
        while(edge_temp->next) {
        edge_temp=edge_temp->next;
        }
        EDGE *temp=(EDGE *)malloc(sizeof(EDGE)*1);
        temp->node=node2;
        temp->next=NULL;
        edge_temp->next=temp;
        temp->distance=weight;
        // temp->distance=sqrtf(pow((node1->x-node2->x),2)+ pow((node1->y-node2->y),2));
    } else {
        node1->edges=(EDGE *)malloc(sizeof(EDGE)*1);
        node1->edges->node=node2;
        node1->edges->next=NULL;
        node1->edges->distance=weight;
        // node1->edges->distance=sqrtf(pow((node1->x-node2->x),2)+ pow((node1->y-node2->y),2));
    }
    if(node2->edges) {
        EDGE *edge_temp;
        edge_temp=node2->edges;
        while(edge_temp->next) {
            edge_temp=edge_temp->next;
        }
        EDGE *temp=(EDGE *)malloc(sizeof(EDGE)*1);
        temp->node=node1;
        temp->next=NULL;
        edge_temp->next=temp;
        temp->distance=weight;
        //temp->distance=sqrtf(pow((node1->x-node2->x),2)+ pow((node1->y-node2->y),2));
    } else {
        node2->edges=(EDGE *)malloc(sizeof(EDGE)*1);
        node2->edges->node=node1;
        node2->edges->next=NULL;
        node2->edges->distance=weight;
       // node2->edges->distance=sqrtf(pow((node1->x-node2->x),2)+ pow((node1->y-node2->y),2));
    }
    return 0;
}

void readEdgeFile(char *input_filename) {
    char src[50];
    char dest[50];
    float weight;
    FILE *input;
    if (!(input = fopen(input_filename, "r"))) {
        fprintf(stderr, "Unable to open input file\n");
        return;
    }
    while(fscanf(input, "%s %s %f", src, dest, &weight) == 3) {
        addEdge(src, dest, weight);
    }
    fclose(input);
}
