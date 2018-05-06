#include "StickerSheet.h"

using namespace cs225;
using namespace std;

StickerSheet::StickerSheet(const Image &picture, unsigned max) {
    base_ = new Image(picture);
    max_ = max;
    sticker_ = new Image*[max];
    x_ = new unsigned int[max];
    y_ = new unsigned int[max];
    for (unsigned i = 0; i < max; i++) {
        sticker_[i] = NULL;
        x_[i] = 0;
        y_[i] = 0;
    }
    index_ = new unsigned int[max];
}

StickerSheet::~StickerSheet() {
    if (base_ != NULL) {
        delete base_;
    }
    _delete();
}

StickerSheet::StickerSheet(const StickerSheet &other) {
    _copy(other);
}

const StickerSheet & StickerSheet::operator=(const StickerSheet &other) {
    _copy(other);
    return *this;
}

void StickerSheet::changeMaxStickers(unsigned max) {
    if (max == max_) {
        return;
    }

    Image **tempSticker = new Image*[max];
    unsigned int *tempIndex = new unsigned int[max];
    unsigned int *tempX = new unsigned int[max];
    unsigned int *tempY = new unsigned int[max];

    if (max > max_) { // newMax > max_
        for (unsigned int i = 0; i < max; i++) {
            if (i >= max_) {
                tempSticker[i] = NULL;
            } else {
                tempSticker[i] = sticker_[i];
                tempIndex[i] = index_[i];
                tempX[i] = x_[i];
                tempY[i] = y_[i];
            }
        }
    } else { // newMax < max_
        for (unsigned int i = 0; i < max; i++) {
            tempSticker[i] = sticker_[i];
            tempIndex[i] = index_[i];
            tempX[i] = x_[i];
            tempY[i] = y_[i];
        }
    }
    _delete();
    sticker_ = tempSticker;
    index_ = tempIndex;
    x_ = tempX;
    y_ = tempY;
    max_ = max;
}

int StickerSheet::addSticker(Image &sticker, unsigned x, unsigned y) {
    for (unsigned int i = 0; i < max_; i++) {
        if (sticker_[i] == NULL) {
            sticker_[i] = &sticker;
            index_[i] = i;
            x_[i] = x;
            y_[i] = y;
            // cout << "Add sticker " << i << " at " << x << ", " << y << endl;
            return 0; // Success
        }
    }
    return -1; // Failed to add
}

bool StickerSheet::translate(unsigned index, unsigned x, unsigned y) {
    if (index > max_) {
        return false;
    } else if (sticker_[index] == NULL) {
        return false;
    } else {
        x_[index] = x;
        y_[index] = y;
        return true;
    }
}

void StickerSheet::removeSticker(unsigned index) {
    if (index < max_) {
        // delete sticker_[index];
        sticker_[index] = NULL;
        x_[index] = 0;
        y_[index] = 0;
        // cout << "Remove sticker " << index << endl;
    } else {
        return;
    }
}

Image * StickerSheet::getSticker(unsigned index) const {
    if (index < max_) {
        return sticker_[index];
    } else {
        return NULL;
    }
}

Image StickerSheet::render() const {
    for (unsigned int i = 0; i < max_; i++) { // Go over each sticker
        if (sticker_[i] != NULL) { // If it is a sticker
            // cout << "Rendering sticker " << i << endl;
            for (unsigned x = 0; x < sticker_[i]->width(); x++) {
                for (unsigned y = 0; y < sticker_[i]->height(); y++) {
                    if (x+x_[i] < base_->width() && y+y_[i] < base_->height()) { // If target location is within the base range
                        HSLAPixel & basePixel = base_->getPixel(x+x_[i], y+y_[i]);
                        HSLAPixel & stickerPixel = sticker_[i]->getPixel(x, y);
                        if (stickerPixel.a != 0) {
                            basePixel.h = stickerPixel.h;
                            basePixel.s = stickerPixel.s;
                            basePixel.l = stickerPixel.l;
                            basePixel.a = stickerPixel.a;
                        }
                    }
                }
            }
        }
    }
    return *base_;
}

void StickerSheet::_delete() {
    if (sticker_ != NULL) delete[] sticker_;
    if (index_ != NULL) delete[] index_;
    if (x_ != NULL) delete[] x_;
    if (y_ != NULL) delete[] y_;
}

void StickerSheet::_copy(const StickerSheet &other) {
    base_ = new Image();
    *base_ = *other.base_;
    max_ = other.max_;
    sticker_ = new Image*[max_];
    x_ = new unsigned int[max_];
    y_ = new unsigned int[max_];
    index_ = new unsigned int[max_];
    for (unsigned i = 0; i < max_; i++) {
        sticker_[i] = NULL;
        x_[i] = 0;
        y_[i] = 0;
    }
    for (unsigned int i = 0; i < max_; i++) {
        if (other.sticker_[i] != NULL) {
            sticker_[i] = new Image();
            *sticker_[i] = *other.sticker_[i];
            index_[i] = other.index_[i];
            x_[i] = other.x_[i];
            y_[i] = other.y_[i];
        }
    }
}
