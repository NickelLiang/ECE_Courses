/**
 * @file kdtree.cpp
 * Implementation of KDTree class.
 */

#include <utility>
#include <algorithm>

using namespace std;

template <int Dim>
bool KDTree<Dim>::smallerDimVal(const Point<Dim>& first,
                                const Point<Dim>& second, int curDim) const
{
    if (first[curDim] != second[curDim]) return (first[curDim] < second[curDim]);
    return (first < second);
}

template <int Dim>
bool KDTree<Dim>::shouldReplace(const Point<Dim>& target,
                                const Point<Dim>& currentBest,
                                const Point<Dim>& potential) const
{
    double curDistance = 0;
    double potDistance = 0;
    for (int i = 0; i < Dim; i ++) {
        curDistance += (currentBest[i] - target[i]) * (currentBest[i] - target[i]);
        potDistance += (potential[i] - target[i]) * (potential[i] - target[i]);
    }
    if (curDistance != potDistance) return (potDistance < curDistance);
    return (potential < currentBest);
}

template <int Dim>
KDTree<Dim>::KDTree(const vector<Point<Dim>>& newPoints)
{
    points = newPoints;
    conRecursive(points, 0, points.size() - 1, 0);
    treeRecursive(points, 0, points.size() - 1, &root);
}

template <int Dim>
void KDTree<Dim>::conRecursive(vector<Point<Dim>> &points, int tl, int tr, int dimension) {
    if (tl >= tr) return;
    sorting(points, tl, tr, dimension, (tl + tr) / 2);
    conRecursive(points, tl, (tl + tr) / 2 - 1, (dimension + 1) % Dim);
    conRecursive(points, (tl + tr) / 2 + 1, tr, (dimension + 1) % Dim);
}

template <int Dim>
void KDTree<Dim>::sorting(vector<Point<Dim>> &points, int tl, int tr, int dimension, int median) {
    if (tl >= tr) return;
    int temp = (tl + tr) / 2;
    Point<Dim> midValue = points[temp];
    swap(points, temp, tr);
    temp = tl;
    for (int i = tl; i < tr; i ++) {
        if (smallerDimVal(points[i], midValue, dimension)) {
            swap(points, i, temp);
            temp ++;
        }
    }
    swap(points, temp, tr);
    if (temp == median) return;
    if (temp < median) {
        sorting(points, temp + 1, tr, dimension, median);
        return;
    }
    sorting(points, tl, temp - 1, dimension, median);
    return;
}

template <int Dim>
void KDTree<Dim>::swap(vector<Point<Dim>> &points, int first, int second) {
  Point<Dim> temp = points[first];
  points[first] = points[second];
  points[second] = temp;
}

template <int Dim>
void KDTree<Dim>::treeRecursive(vector<Point<Dim>> &points, int tl, int tr, KDTreeNode **subroot) {
   if (tl > tr) return;
   *subroot = new KDTreeNode(points[(tl + tr) / 2]);
   treeRecursive(points, tl, (tl + tr) / 2 - 1, &(*subroot)->left);
   treeRecursive(points, (tl + tr) / 2 + 1, tr, &(*subroot)->right);
}

template <int Dim>
KDTree<Dim>::KDTree(const KDTree& other) {
    //copy(root, other);
}

template <int Dim>
const KDTree<Dim>& KDTree<Dim>::operator=(const KDTree& rhs) {
    // if (this != &rhs) {
    //     clear(root);
    //     copy(root, rhs);
    // }
    // return *this;
}

template <int Dim>
KDTree<Dim>::~KDTree() {
    // clear(root);
}

// template <int Dim>
// void KDTree<Dim>::clear(KDTreeNode *subroot) {
//     if (subroot->left != NULL) clear(subroot->left);
//     if (subroot->right != NULL) clear(subroot->right);
//     delete subroot;
//     subroot = NULL;
// }
//
// template <int Dim>
// void KDTree<Dim>::copy(KDTreeNode *newRoot, KDTreeNode *subroot) {
//     if (subroot == NULL) return;
//     newRoot = new KDTreeNode(subroot->point);
//     copy(newRoot->left, subroot->left);
//     copy(newRoot->right, subroot->right);
//     return;
// }

template <int Dim>
Point<Dim> KDTree<Dim>::findNearestNeighbor(const Point<Dim>& query) const
{
    bool checkFirst = true;
    Point<Dim> result;
    findHelper(query, result, checkFirst, root, 0);
    return result;
}

template <int Dim>
void KDTree<Dim>::findHelper(const Point<Dim> &query, Point<Dim> &result, bool &checkFirst, KDTreeNode *subroot, int dimension) const {
    if (subroot == NULL) return;
    if (subroot->left == NULL && subroot->right == NULL) {
        if (checkFirst) {
            checkFirst = false;
            result = subroot->point;
        }
        else {
            if (shouldReplace(query, result, subroot->point)) result = subroot->point;
        }
        return;
    }
    if (smallerDimVal(query, subroot->point, dimension)) {
        findHelper(query, result, checkFirst, subroot->left, (dimension + 1) % Dim);
        if (shouldReplace(query, result, subroot->point)) result = subroot->point;
        double radius = 0;
        for (int i = 0; i < Dim; i ++) {
            radius += (query[i] - result[i]) * (query[i] - result[i]);
        }
        double dist = (query[dimension] - subroot->point[dimension]) * (query[dimension] - subroot->point[dimension]);
        if (dist <= radius) findHelper(query, result, checkFirst, subroot->right, (dimension + 1) % Dim);
    }
    else {
        findHelper(query, result, checkFirst, subroot->right, (dimension + 1) % Dim);
        if (shouldReplace(query, result, subroot->point)) result = subroot->point;
        double radius = 0;
        for (int i = 0; i < Dim; i ++) {
            radius += (query[i] - result[i]) * (query[i] - result[i]);
        }
        double dist = (query[dimension] - subroot->point[dimension]) * (query[dimension] - subroot->point[dimension]);
        if (dist <= radius) findHelper(query, result, checkFirst, subroot->left, (dimension + 1) % Dim);
    }
}
