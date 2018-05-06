#include "potd.h"
#include <iostream>

using namespace std;

string stringList(Node *head) {
    if (head == NULL) {
        return "Empty List";
    }
    int counter = 0;
    string ret = "";
    while (head != NULL) {
        ret += "Node ";
        ret += counter;
        ret += ": ";
        ret += head->data_;
        if (head->next_ != NULL) {
            ret += " -> ";
        }
        counter ++;
        head = head->next_;
    }
    return ret;
}
