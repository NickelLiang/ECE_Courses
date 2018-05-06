#include <cmath>
#include <iterator>
#include <iostream>
#include <map>

#include "../cs225/HSLAPixel.h"
#include "../cs225/PNG.h"
#include "../Point.h"

#include "ImageTraversal.h"

/**
 * Calculates a metric for the difference between two pixels, used to
 * calculate if a pixel is within a tolerance.
 *
 * @param p1 First pixel
 * @param p2 Second pixel
 * @return the difference between two HSLAPixels
 */
double ImageTraversal::calculateDelta(const HSLAPixel & p1, const HSLAPixel & p2) {
    double h = fabs(p1.h - p2.h);
    double s = p1.s - p2.s;
    double l = p1.l - p2.l;

    // Handle the case where we found the bigger angle between two hues:
    if (h > 180) { h = 360 - h; }
    h /= 360;

    return sqrt( (h*h) + (s*s) + (l*l) );
}

/**
 * Default iterator constructor.
 */
ImageTraversal::Iterator::Iterator() {
    itr_ = NULL;
}

ImageTraversal::Iterator::Iterator(ImageTraversal * itr) {
    itr_ = itr;
}

/**
 * Iterator increment opreator.
 *
 * Advances the traversal of the image.
 */
ImageTraversal::Iterator & ImageTraversal::Iterator::operator++() {
    /* Add points around onto stack/queue */
    if (!itr_->empty())
        itr_->add(itr_->pop());
    while (!itr_->empty()) {
        Point current = itr_->peek();
        if (itr_->m[current.x][current.y] == false)
            break;
        else
            itr_->pop();
    }
    return *this;
}

/**
 * Iterator accessor opreator.
 *
 * Accesses the current Point in the ImageTraversal.
 */
Point ImageTraversal::Iterator::operator*() {
    return itr_->peek();
}

/**
 * Iterator inequality operator.
 *
 * Determines if two iterators are not equal.
 */
bool ImageTraversal::Iterator::operator!=(const ImageTraversal::Iterator &other) {
    if ((this->itr_ == NULL || this->itr_->empty()) && (other.itr_ == NULL || other.itr_->empty()))
        return false;
    return true;
}
