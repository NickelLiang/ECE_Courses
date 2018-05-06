#include <iterator>
#include <cmath>
#include <list>
#include <stack>
#include <map>

#include "../cs225/PNG.h"
#include "../Point.h"

#include "ImageTraversal.h"
#include "DFS.h"

/**
 * Initializes a depth-first ImageTraversal on a given `png` image,
 * starting at `start`, and with a given `tolerance`.
 * @param png The image this DFS is going to traverse
 * @param start The start point of this DFS
 * @param tolerance If the current point is too different (difference larger than tolerance) with the start point,
 * it will not be included in this DFS
 */
DFS::DFS(const PNG & png, const Point & start, double tolerance) {
    png_ = png;
    start_ = start;
    tolerance_ = tolerance;
    for (unsigned int x = 0; x < png.width(); x++)
        for (unsigned int y = 0; y < png.height(); y++)
            m[x][y] = false;
}

/**
 * Returns an iterator for the traversal starting at the first point.
 */
ImageTraversal::Iterator DFS::begin() {
    s.push(start_);
    m[start_.x][start_.y] = true;
    return ImageTraversal::Iterator(this);
}

/**
 * Returns an iterator for the traversal one past the end of the traversal.
 */
ImageTraversal::Iterator DFS::end() {
    return ImageTraversal::Iterator();
}

/**
 * Adds a Point for the traversal to visit at some point in the future.
 */
void DFS::add(const Point & point) {
    int w = png_.width();
    int h = png_.height();
    int x = point.x;
    int y = point.y;
    HSLAPixel startPixel = png_.getPixel(start_.x, start_.y);
    m[x][y] = true;
    if (x + 1 < w)
        if (calculateDelta(startPixel, png_.getPixel(x+1, y)) < tolerance_ && m[x+1][y] == false)
            s.push(Point(x+1, y));
    if (y + 1 < h)
        if (calculateDelta(startPixel, png_.getPixel(x, y+1)) < tolerance_ && m[x][y+1] == false)
            s.push(Point(x, y+1));
    if (x - 1 >= 0)
        if (calculateDelta(startPixel, png_.getPixel(x-1, y)) < tolerance_ && m[x-1][y] == false)
            s.push(Point(x-1, y));
    if (y - 1 >= 0)
        if (calculateDelta(startPixel, png_.getPixel(x, y-1)) < tolerance_ && m[x][y-1] == false)
            s.push(Point(x, y-1));
}

/**
 * Removes and returns the current Point in the traversal.
 */
Point DFS::pop() {
    Point ret = s.top();
    s.pop();
    return ret;
}

/**
 * Returns the current Point in the traversal.
 */
Point DFS::peek() const {
    return s.top();
}

/**
 * Returns true if the traversal is empty.
 */
bool DFS::empty() const {
    return s.empty();
}