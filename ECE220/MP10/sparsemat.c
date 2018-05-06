// This program use the concept of linked list to manage a sparse array.
// Check each function for definition and usage
// ECE220 MP10, 11/11/17
// Nickel Liang, zuodong2@illinois.edu

#include "sparsemat.h"
#include <stdio.h>
#include <stdlib.h>

void insertionSort(sp_tuples *structure);
void sortedInsert(sp_tuples *structure, sp_tuples_node **head, sp_tuples_node *new);
void removeRedundant(sp_tuples *mat_t);

// This function can sort a list via insertion sort.
void insertionSort(sp_tuples *structure) {
    sp_tuples_node *sorted = NULL;
    sp_tuples_node *current = structure->tuples_head;
    while (current != NULL) {
        sp_tuples_node *next = current->next;
        sortedInsert(structure, &(sorted), current);
        current = next;
    }
    structure->tuples_head = sorted;
}

// This function insert a new node into a ordered list.
void sortedInsert(sp_tuples *structure, sp_tuples_node **head, sp_tuples_node *new) {
    sp_tuples_node *current = NULL;
    int max = structure->n;
    if (*head == NULL || (max*(*head)->row+(*head)->col) >= (max*new->row+new->col)) {
        new->next = *head;
        *head = new;
    } else {
        current = *head;
        while ((current->next != NULL) && (max*((current->next)->row)+((current->next)->col)) <= (max*new->row+new->col)) {
            current = current->next;
        }
        new->next = current->next;
        current->next = new;
    }
}

// This function can remove multiple data that has same coordinate. It can also erase zero
// valued tuples.
void removeRedundant(sp_tuples *mat_t) {
    sp_tuples_node *head = mat_t->tuples_head;
    sp_tuples_node *prev = NULL;
    while (head != NULL) {
        if (head->next != NULL && (head->next)->row == head->row && (head->next)->col == head->col) {
            if (prev != NULL) {
                prev->next = head->next;
                free(head);
                head = prev->next;
                mat_t->nz--;
            } else {
                mat_t->tuples_head = head->next;
                free(head);
                head = mat_t->tuples_head;
                mat_t->nz--;
            }
        }
        prev = head;
        head = head->next;
    }

    head = mat_t->tuples_head;
    prev = NULL;
    while (head != NULL) {
        if (head->value == 0) {
            if (prev != NULL) {
                prev->next = head->next;
                free(head);
                head = prev->next;
                mat_t->nz--;
            } else {
                mat_t->tuples_head = head->next;
                free(head);
                head = mat_t->tuples_head;
                mat_t->nz--;
            }
        }
        prev = head;
        head = head->next;
    }
}

// load_tuples should open a file with the name 'input_file', read the data from the file,
// and return a matrix of the list of row major ordered tuples type.
sp_tuples * load_tuples(char* input_file) {
    // Create tuple list, read every entry of the file to the list
    sp_tuples *newList = (sp_tuples *)malloc(sizeof(sp_tuples));
    FILE *file = fopen(input_file, "r");
    fscanf(file, "%d %d\n", &newList->m, &newList->n);
    sp_tuples_node *newNode = (sp_tuples_node *)malloc(sizeof(sp_tuples_node));
    sp_tuples_node *preNode = (sp_tuples_node *)malloc(sizeof(sp_tuples_node));
    newList->nz = 0;
    newList->tuples_head = newNode;
    while (3 == fscanf(file, "%d %d %lf\n", &newNode->row, &newNode->col, &newNode->value)) {
        newList->nz++;
        newNode->next = NULL;
        preNode = newNode;
        newNode = (sp_tuples_node *)malloc(sizeof(sp_tuples_node));
        preNode->next = newNode;
    }
    preNode->next = NULL;
    free(newNode);
    fclose(file);

    insertionSort(newList);
    removeRedundant(newList);

    return newList;
}

// Give a coordinate in a linked list, return the value.
double gv_tuples(sp_tuples * mat_t, int row, int col) {
    sp_tuples_node *head = mat_t->tuples_head;
    while (head != NULL) {
        if (head->row == row && head->col == col) {
            return head->value;
        }
        head = head->next;
    }
    return 0;
}

// Reset the valueof a node.
void set_tuples(sp_tuples * mat_t, int row, int col, double value) {
    sp_tuples_node *head = mat_t->tuples_head;
    sp_tuples_node *prev = NULL;
    while (head != NULL) {
        if (head->row == row && head->col == col) { //If we found it in the list
            if (value == 0) { //If we want to set it to zero
                if (prev == NULL) { //If this is the first item in the list
                    prev = head;
                    head = head->next;
                    mat_t->tuples_head = head;
                    free(prev);
                    prev = NULL;
                } else {
                    prev->next = head->next;
                    free(head);
                    head = prev->next;
                }
                mat_t->nz--;
                return;
            } else { //If we want to set it to other value
                head->value = value;
                return;
            }
        }
        prev = head;
        head = head->next;
    }
    if (head == NULL) { //If we didn't found it in the list
        if (value != 0) { //If we are adding a non-zero value
            sp_tuples_node *new = (sp_tuples_node *)malloc(sizeof(sp_tuples_node));
            new->row = row;
            new->col = col;
            new->value = value;
            new->next = NULL;
            sortedInsert(mat_t, &(mat_t->tuples_head), new);
            mat_t->nz++;
        }
    }
}

// Save a tuple list into a file.
void save_tuples(char * file_name, sp_tuples * mat_t) {
    FILE *file = fopen(file_name, "w");
    fprintf(file, "%d %d\n", mat_t->m, mat_t->n);
    sp_tuples_node *head = mat_t->tuples_head;
    while (head != NULL) {
        fprintf(file, "%d %d %lf\n", head->row, head->col, head->value);
        head = head->next;
    }
    fclose(file);
}

// Perform tuple addition
sp_tuples * add_tuples(sp_tuples * matA, sp_tuples * matB) {
    if (matA->m != matB->m || matA->n != matB->n) {
        return NULL;
    }
    sp_tuples *matC = (sp_tuples *)malloc(sizeof(sp_tuples));
    matC->m = matA->m;
    matC->n = matA->n;
    matC->nz = 0;
    matC->tuples_head = NULL;

    sp_tuples_node *head = matA->tuples_head;
    while (head != NULL) {
        set_tuples(matC, head->row, head->col, head->value);
        head = head->next;
    }

    head = matB->tuples_head;
    while (head != NULL) {
        set_tuples(matC, head->row, head->col, head->value + gv_tuples(matC, head->row, head->col));
        head = head->next;
    }

	return matC;
}

// Perform tuple multiplication.
sp_tuples * mult_tuples(sp_tuples * matA, sp_tuples * matB) {
    if (matA->n != matB->m) {
        return NULL;
    }
    sp_tuples *matC = (sp_tuples *)malloc(sizeof(sp_tuples));
    matC->m = matA->m;
    matC->n = matB->n;
    matC->nz = 0;
    matC->tuples_head = NULL;

    sp_tuples_node *headA = matA->tuples_head;

    while (headA != NULL) {
        int iA = headA->row;
        int jA = headA->col;
        sp_tuples_node *headB = matB->tuples_head;
        while (headB != NULL) {
            int iB = headB->row;
            int jB = headB->col;
            if (iB == jA && 0 != gv_tuples(matB, iB, jB)) {
                set_tuples(matC, iA, jB, gv_tuples(matC, iA, jB)+gv_tuples(matA, iA, jA)*gv_tuples(matB, iB, jB));
            }
            headB = headB->next;
        }
        headA = headA->next;
    }

    return matC;
}

// Free memory
void destroy_tuples(sp_tuples * mat_t) {
    sp_tuples_node *head = mat_t->tuples_head;
    sp_tuples_node *prev = NULL;
    while (head != NULL) {
        prev = head;
        head = prev->next;
        free(prev);
    }
    free(mat_t);
}
