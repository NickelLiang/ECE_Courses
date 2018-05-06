#ifndef MyColorPicker_H
#define MyColorPicker_H

#include <algorithm>
#include "ColorPicker.h"
#include "../cs225/HSLAPixel.h"
#include "../Point.h"

using namespace cs225;

/**
 * A color picker class using your own color picking algorithm
 */
class MyColorPicker : public ColorPicker {
public:
    MyColorPicker(unsigned long hex);
    HSLAPixel getColor(unsigned x, unsigned y);

private:
    unsigned long hex_;
    double h_;
    double s_;
    double l_;
};

#endif
