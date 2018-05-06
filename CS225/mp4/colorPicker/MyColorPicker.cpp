#include "../cs225/HSLAPixel.h"
#include "../Point.h"

#include <algorithm>
#include <cmath>
#include <iostream>
#include "ColorPicker.h"
#include "MyColorPicker.h"

using namespace cs225;
using namespace std;

MyColorPicker::MyColorPicker(unsigned long hex) {
    hex_ = hex;
    unsigned originalR = (unsigned)((hex & 0xFF0000) >> 16);
    unsigned originalG = (unsigned)((hex & 0x00FF00) >> 8);
    unsigned originalB = (unsigned)(hex & 0x0000FF);
    // cout << "R " << originalR << " G " << originalG << " B " << originalB << endl;
    double R = (double)originalR / 255;
    double G = (double)originalG / 255;
    double B = (double)originalB / 255;
    double ma = (double)max(R, max(G, B));
    double mi = (double)min(R, min(G, B));
    double delta = ma - mi;
    // cout << R << " " << G << " " << B << endl;
    // cout << ma << " " << mi << " " << delta << endl;

    l_ = (ma + mi) / 2;
    s_ = delta / (1 - abs(2 * l_ - 1));
    if (delta == 0) {
        h_ = 0;
    } else if (ma == R) {
        // cout << (G-B)/delta-(int)(((G-B)/delta)/6)*6 << endl;
        h_ = 60 * ((G-B)/delta-(int)(((G-B)/delta)/6)*6);
    } else if (ma == G) {
        h_ = 60 * (((B-R)/delta)+2);
    } else if (ma == B) {
        h_ = 60 * (((R-G)/delta)+4);
    }
    // cout << "H " << h_ << " S " << s_ << " L " << l_ << endl;
}

/**
 * Picks the color for pixel (x, y).
 * Using your own algorithm
 */
HSLAPixel MyColorPicker::getColor(unsigned x, unsigned y) {
    return HSLAPixel(h_, s_, l_);
}
