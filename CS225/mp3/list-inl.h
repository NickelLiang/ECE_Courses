/**
 * @file list.cpp
 * Doubly Linked List (MP 3).
 */

/**
 * Destroys the current List. This function should ensure that
 * memory does not leak on destruction of a list.
 */
template <class T>
List<T>::~List() {
    clear();
}

/**
 * Destroys all dynamically allocated memory associated with the current
 * List class.
 */
template <class T>
void List<T>::clear() {
    ListNode* curr = head_;
    ListNode* prev = NULL;
    while (curr != NULL) {
        prev = curr;
        curr = curr->next;
        delete prev;
    }
    head_ = NULL;
}

/**
 * Inserts a new node at the front of the List.
 * This function **SHOULD** create a new ListNode.
 *
 * @param ndata The data to be inserted.
 */
template <class T>
void List<T>::insertFront(T const & ndata) {
    ListNode* node = new ListNode(ndata);
    if (head_ == NULL) {
        head_ = node;
        tail_ = node;
    } else {
        node->next = head_;
        head_->prev = node;
        head_ = node;
    }
    length_++;
}

/**
 * Inserts a new node at the back of the List.
 * This function **SHOULD** create a new ListNode.
 *
 * @param ndata The data to be inserted.
 */
template <class T>
void List<T>::insertBack(const T & ndata) {
    ListNode* node = new ListNode(ndata);
    if (head_ == NULL) {
        head_ = node;
        tail_ = node;
    } else {
        node->prev = tail_;
        tail_->next = node;
        tail_ = node;
    }
    length_++;
}

/**
 * Reverses the current List.
 */
template <class T>
void List<T>::reverse() {
    reverse(head_, tail_);
}

/**
 * Helper function to reverse a sequence of linked memory inside a List,
 * starting at startPoint and ending at endPoint. You are responsible for
 * updating startPoint and endPoint to point to the new starting and ending
 * points of the rearranged sequence of linked memory in question.
 *
 * @param startPoint A pointer reference to the first node in the sequence
 *  to be reversed.
 * @param endPoint A pointer reference to the last node in the sequence to
 *  be reversed.
 */
template <class T>
void List<T>::reverse(ListNode *& startPoint, ListNode *& endPoint) {
    if (startPoint == NULL || endPoint == NULL) {
        return;
    }

    ListNode* before = startPoint->prev;
    ListNode* curr = startPoint;
    ListNode* temp = NULL;
    ListNode* after = endPoint->next;
    while (curr != after) {
        temp = curr->prev;
        curr->prev = curr->next;
        curr->next = temp;
        curr = curr->prev;
    }
    endPoint = startPoint;
    startPoint = temp->prev;

    if (before == NULL) {
        head_ = startPoint;
        startPoint->prev = NULL;
    } else {
        before->next = startPoint;
        startPoint->prev = before;
    }
    if (after == NULL) {
        tail_ = endPoint;
        endPoint->next = NULL;
    } else {
        after->prev = endPoint;
        endPoint->next = after;
    }
}

/**
 * Reverses blocks of size n in the current List. You should use your
 * reverse( ListNode * &, ListNode * & ) helper function in this method!
 *
 * @param n The size of the blocks in the List to be reversed.
 */
template <class T>
void List<T>::reverseNth(int n) {
    if (head_ == NULL) {
        return;
    }
    if (length_ <= n) {
        reverse();
        return;
    }
    if (n <= 1) {
        return;
    }

    ListNode* start = head_;
    ListNode* end = head_;
    for (int i = 0; i < length_/n; i++) {
        for (int j = 0; j < n - 1; j++) {
            end = end->next;
        }
        reverse(start, end);
        start = end->next;
        end = start;
    }

    if ((length_ % n) != 0) {
        reverse(start, tail_);
    }
}

/**
 * Modifies the List using the waterfall algorithm.
 * Every other node (starting from the second one) is removed from the
 * List, but appended at the back, becoming the new tail. This continues
 * until the next thing to be removed is either the tail (**not necessarily
 * the original tail!**) or NULL.  You may **NOT** allocate new ListNodes.
 * Note that since the tail should be continuously updated, some nodes will
 * be moved more than once.
 */
template <class T>
void List<T>::waterfall() {
    if (head_ == NULL) {
        return;
    }
    ListNode* curr = head_;
    bool skip = true;
    while (curr != tail_ && curr != NULL) {
        if (skip == false) {
            ListNode* prev = curr->prev;
            ListNode* next = curr->next;
            prev->next = next;
            next->prev = prev;
            curr->prev = tail_;
            curr->next = NULL;
            tail_->next = curr;
            tail_ = curr;
            curr = next;
        } else {
            curr = curr->next;
        }
        skip = !skip;
    }
}

/**
 * Splits the given list into two parts by dividing it at the splitPoint.
 *
 * @param splitPoint Point at which the list should be split into two.
 * @return The second list created from the split.
 */
template <class T>
List<T> List<T>::split(int splitPoint) {
    if (splitPoint > length_)
        return List<T>();

    if (splitPoint < 0)
        splitPoint = 0;

    ListNode * secondHead = split(head_, splitPoint);

    int oldLength = length_;
    if (secondHead == head_) {
        // current list is going to be empty
        head_ = NULL;
        tail_ = NULL;
        length_ = 0;
    } else {
        // set up current list
        tail_ = head_;
        while (tail_ -> next != NULL)
            tail_ = tail_->next;
        length_ = splitPoint;
    }

    // set up the returned list
    List<T> ret;
    ret.head_ = secondHead;
    ret.tail_ = secondHead;
    if (ret.tail_ != NULL) {
        while (ret.tail_->next != NULL)
            ret.tail_ = ret.tail_->next;
    }
    ret.length_ = oldLength - splitPoint;
    return ret;
}

/**
 * Helper function to split a sequence of linked memory at the node
 * splitPoint steps **after** start. In other words, it should disconnect
 * the sequence of linked memory after the given number of nodes, and
 * return a pointer to the starting node of the new sequence of linked
 * memory.
 *
 * This function **SHOULD NOT** create **ANY** new List or ListNode objects!
 *
 * @param start The node to start from.
 * @param splitPoint The number of steps to walk before splitting.
 * @return The starting node of the sequence that was split off.
 */
template <class T>
typename List<T>::ListNode * List<T>::split(ListNode * start, int splitPoint) {
    ListNode* ret = start;
    for (int i = 0; i < splitPoint; i++) {
        ret = ret->next;
    }
    ret->prev->next = NULL;
    ret->prev = NULL;
    return ret;
}

/**
 * Merges the given sorted list into the current sorted list.
 *
 * @param otherList List to be merged into the current list.
 */
template <class T>
void List<T>::mergeWith(List<T> & otherList) {
    // set up the current list
    head_ = merge(head_, otherList.head_);
    tail_ = head_;

    // make sure there is a node in the new list
    if (tail_ != NULL) {
        while (tail_->next != NULL)
            tail_ = tail_->next;
    }
    length_ = length_ + otherList.length_;

    // empty out the parameter list
    otherList.head_ = NULL;
    otherList.tail_ = NULL;
    otherList.length_ = 0;
}

/**
 * Helper function to merge two **sorted** and **independent** sequences of
 * linked memory. The result should be a single sequence that is itself
 * sorted.
 *
 * This function **SHOULD NOT** create **ANY** new List objects.
 *
 * @param first The starting node of the first sequence.
 * @param second The starting node of the second sequence.
 * @return The starting node of the resulting, sorted sequence.
 */
template <class T>
typename List<T>::ListNode * List<T>::merge(ListNode* first, ListNode* second) {
    ListNode* head;;
    ListNode* firstPtr;
    ListNode* secondPtr;
    if (second->data < first->data) {
        head = second;
        firstPtr = head->next;
        secondPtr = first;
    } else {
        head = first;
        firstPtr = head->next;
        secondPtr = second;
    }

    // cout<<"HEAD   "; printNode(cout, head); cout<<endl;
    // cout<<"FIRST  "; printNode(cout, firstPtr); cout<<endl;
    // cout<<"SECOND "; printNode(cout, secondPtr); cout<<endl;

    while (firstPtr != NULL && secondPtr != NULL) {
        if (secondPtr->data < firstPtr->data) {
            firstPtr->prev->next = secondPtr;
            secondPtr->prev = firstPtr->prev;
            secondPtr = secondPtr->next;
            firstPtr->prev->next->next = firstPtr;
            firstPtr->prev = firstPtr->prev->next;
        } else {
            firstPtr = firstPtr->next;
        }
    }

    if (firstPtr == NULL) {
        firstPtr = head;
        while (firstPtr->next != NULL) {
            firstPtr = firstPtr->next;
        }
        firstPtr->next = secondPtr;
        secondPtr->prev = firstPtr;
    }
    second = NULL;
    return head;
}

/**
 * Sorts the current list by applying the Mergesort algorithm.
 */
template <class T>
void List<T>::sort() {
    if (empty())
        return;
    head_ = mergesort(head_, length_);
    tail_ = head_;
    while (tail_->next != NULL)
        tail_ = tail_->next;
}

/**
 * Sorts a chain of linked memory given a start node and a size.
 * This is the recursive helper for the Mergesort algorithm (i.e., this is
 * the divide-and-conquer step).
 *
 * @param start Starting point of the chain.
 * @param chainLength Size of the chain to be sorted.
 * @return A pointer to the beginning of the now sorted chain.
 */
template <class T>
typename List<T>::ListNode* List<T>::mergesort(ListNode * start, int chainLength) {
    if (chainLength == 1) {
        return start;
    }
    int size = chainLength / 2;
    ListNode* left = start;
    ListNode* right = split(start, size);
    return merge(mergesort(left, size), mergesort(right, chainLength - size));
}
