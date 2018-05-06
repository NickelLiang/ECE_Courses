#include "Image.h"

using namespace cs225;

void Image::lighten() {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            pixel.l += 0.1;
            if (pixel.l >= 1) pixel.l = 1;
        }
    }
}

void Image::lighten(double amount) {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            pixel.l += amount;
            if (pixel.l >= 1) pixel.l = 1;
        }
    }
}

void Image::darken() {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            pixel.l -= 0.1;
            if (pixel.l <= 0) pixel.l = 0;
        }
    }
}

void Image::darken(double amount) {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            pixel.l -= amount;
            if (pixel.l <= 0) pixel.l = 0;
        }
    }
}

void Image::saturate() {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            pixel.s += 0.1;
            if (pixel.s >= 1) pixel.s = 1;
        }
    }
}

void Image::saturate(double amount) {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            pixel.s += amount;
            if (pixel.s >= 1) pixel.s = 1;
        }
    }
}
void Image::desaturate() {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            pixel.s -= 0.1;
            if (pixel.s <= 0) pixel.s = 0;
        }
    }
}

void Image::desaturate(double amount) {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            pixel.s -= amount;
            if (pixel.s <= 0) pixel.s = 0;
        }
    }
}

void Image::grayscale() {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            pixel.s = 0;
        }
    }
}

void Image::rotateColor(double degrees) {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            pixel.h += degrees;
            if (pixel.h > 360) {
                pixel.h -= 360;
            } else if (pixel.h < 0) {
                pixel.h += 360;
            }
        }
    }
}

void Image::illinify() {
    for (unsigned int x = 0; x < this->width(); x++) {
        for (unsigned int y = 0; y < this->height(); y++) {
            HSLAPixel & pixel = this->getPixel(x, y);
            int distanceOrange = abs(11 - pixel.h);
            if (distanceOrange > 180) distanceOrange = 360 - distanceOrange;
            int distanceBlue = abs(216 - pixel.h);
            if (distanceBlue > 180) distanceBlue = 360 - distanceBlue;
            if (distanceBlue < distanceOrange) {
                pixel.h = 216;
            } else {
                pixel.h = 11;
            }
        }
    }
}

void Image::scale(double factor) {
    unsigned int originalWidth = this->width();
    unsigned int originalHeight = this->height();
    unsigned int newWidth = this->width() * factor;
    unsigned int newHeight = this->height() * factor;
    PNG * image = new PNG(*this);
    this->resize(newWidth, newHeight);
    for (unsigned int x = 0; x < originalWidth; x++) {
        for (unsigned int y = 0; y < originalHeight; y++) {
            HSLAPixel & original = image->getPixel(x, y);
            HSLAPixel & scaled = this->getPixel(x * factor, y * factor);
            scaled.h = original.h;
            scaled.s = original.s;
            scaled.l = original.l;
            scaled.a = original.a;
            if (x * factor + 1 < newWidth) {
                HSLAPixel & insert0 = this->getPixel(x * factor + 1, y * factor);
                insert0.h = original.h;
                insert0.s = original.s;
                insert0.l = original.l;
                insert0.a = original.a;
            }
            if (x * factor + 1 < newWidth && y * factor + 1 < newHeight) {
                HSLAPixel & insert1 = this->getPixel(x * factor + 1, y * factor + 1);
                insert1.h = original.h;
                insert1.s = original.s;
                insert1.l = original.l;
                insert1.a = original.a;
            }
            if (y * factor + 1 < newHeight) {
                HSLAPixel & insert2 = this->getPixel(x * factor, y * factor + 1);
                insert2.h = original.h;
                insert2.s = original.s;
                insert2.l = original.l;
                insert2.a = original.a;
            }
        }
    }
    delete image;
}

void Image::scale(unsigned w, unsigned h) {
    unsigned int originalWidth = this->width();
    unsigned int originalHeight = this->height();
    unsigned int newWidth = this->width() * w;
    unsigned int newHeight = this->height() * h;
    PNG * image = new PNG(*this);
    this->resize(newWidth, newHeight);
    for (unsigned int x = 0; x < originalWidth; x++) {
        for (unsigned int y = 0; y < originalHeight; y++) {
            HSLAPixel & original = image->getPixel(x, y);
            HSLAPixel & scaled = this->getPixel(x * w, y * h);
            scaled.h = original.h;
            scaled.s = original.s;
            scaled.l = original.l;
            scaled.a = original.a;
            if (x * w + 1 < newWidth) {
                HSLAPixel & insert0 = this->getPixel(x * w + 1, y * h);
                insert0.h = original.h;
                insert0.s = original.s;
                insert0.l = original.l;
                insert0.a = original.a;
            }
            if (x * w + 1 < newWidth && y * h + 1 < newHeight) {
                HSLAPixel & insert1 = this->getPixel(x * w + 1, y * h + 1);
                insert1.h = original.h;
                insert1.s = original.s;
                insert1.l = original.l;
                insert1.a = original.a;
            }
            if (y * h + 1 < newHeight) {
                HSLAPixel & insert2 = this->getPixel(x * w, y * h + 1);
                insert2.h = original.h;
                insert2.s = original.s;
                insert2.l = original.l;
                insert2.a = original.a;
            }
        }
    }
    delete image;
}
