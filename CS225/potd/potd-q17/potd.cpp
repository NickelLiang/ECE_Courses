#include "potd.h"
#include <iostream>

using namespace std;

void insertSorted(Node **head, Node *insert) {
    Node *temp;
    temp = *head;
    // *head = insert;
    // while (temp != NULL) {
        // if (temp->data_ < insert->data_) {
        //     temp = temp->next_;
        // } else {
        //     if (temp == *head) {
        //         *head = insert;
        //         break;
        //     } else {
        //         insert->next_ = temp->next_;
        //         temp->next_ = insert;
        //         break;
        //     }
        //
        // }
    // }
    if (*head == NULL) {
        *head = insert;
    } else {
        insert->next_ = (*head)->next_;
        (*head)->next_ = insert;
    }
}
