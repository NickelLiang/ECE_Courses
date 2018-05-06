#include "dsets.h"

void DisjointSets::addelements(int num){
    for(int i = 0; i < num; ++i){
        my_dset.push_back(-1);
    }
}

int DisjointSets::find(int elem){
    if(my_dset[elem] < 0){
        //base case
        return elem;
    }
    //recursive case;
    my_dset[elem] = find(my_dset[elem]);
    return my_dset[elem];
}

//note that we should not assume the arguments are roots
void DisjointSets::setunion(int a, int b){
    int first_root = find(a);
    int second_root = find(b);
    if(first_root == second_root)
        return;
    //they are disjoint. We union them by size
    //(attach tree of smaller size to root node of the other)
    if(my_dset[first_root] > my_dset[second_root]){
        //first tree is smaller
        my_dset[second_root] += my_dset[first_root];
        my_dset[first_root] = second_root;
    } else {
        my_dset[first_root] += my_dset[second_root];
        my_dset[second_root] = first_root;
    }
}

int DisjointSets::size(int elem){
    return (int)my_dset.size();
}
