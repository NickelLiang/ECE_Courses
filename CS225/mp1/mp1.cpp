#include "cs225/PNG.h"
#include "cs225/HSLAPixel.h"
#include "mp1.h"
#include <string>

using namespace cs225;

void rotate(std::string inputFile, std::string outputFile) {
    PNG input;
    input.readFromFile(inputFile);
    int width = input.width();
    int height = input.height();
    PNG output(width, height);
    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            HSLAPixel *inputPixel = input.getPixel(x, y);
            HSLAPixel *outputPixel = output.getPixel(width-1-x, height-1-y);
            outputPixel->h = inputPixel->h;
            outputPixel->s = inputPixel->s;
            outputPixel->l = inputPixel->l;
            outputPixel->a = inputPixel->a;
        }
    }
    output.writeToFile(outputFile);
}

// A new class to contain cartisian coordinate of a point
class Vertice {
    public:
        unsigned int x;
        unsigned int y;
        Vertice(unsigned int a, unsigned int b);
        ~Vertice();
};

// Constructor
Vertice::Vertice(unsigned int a, unsigned int b) {
    x = a;
    y = b;
}

// Destructor
Vertice::~Vertice() {
}

// Find a point on the line between vertice a and b.
// A brute force method, can be optimized in the future.
Vertice * pointOnLine(Vertice a, Vertice b, unsigned int y) {
    unsigned int x = 0;
    if (a.y == std::min(a.y, b.y)) { // a is on top
        if (a.x < b.x) { // a is on left
            x = (b.x*(y-a.y)+a.x*(b.y-y))/(b.y-a.y);
        } else if (a.x > b.x) { // a is on right
            x = (a.x*(b.y-y)+b.x*(y-a.y))/(b.y-a.y);
        } else { // vertical line
            x = a.x;
        }
    } else { // b is on top
        if (a.x > b.x) { // b is on left
            x = (a.x*(y-b.y)+b.x*(a.y-y))/(a.y-b.y);
        } else if (a.x < b.x) { // b is on right
            x = (b.x*(a.y-y)+a.x*(y-b.y))/(a.y-b.y);
        } else { // vertical line
            x = b.x;
        }
    }
    Vertice *point = new Vertice(x, y);
    return point;
}

// Draw a point
void drawPoint(PNG *png, HSLAPixel *color, Vertice a) {
    HSLAPixel *pixel = png->getPixel(a.x, a.y);
    pixel->h = color->h;
    pixel->s = color->s;
    pixel->l = color->l;
    pixel->a = color->a;
}

// Draw a line
void drawLine(PNG *png, HSLAPixel *color, Vertice a, Vertice b) {
    if (a.y == b.y) { // If horizontal line
        for (unsigned int x = std::min(a.x, b.x); x < std::max(a.x, b.x); x++) {
            Vertice *point = new Vertice(x, a.y);
            drawPoint(png, color, *point);
            delete point;
        }
    } else {
        for (unsigned int y = std::min(a.y, b.y); y < std::max(a.y, b.y); y++) {
            Vertice *point = pointOnLine(a, b, y);
            drawPoint(png, color, *point);
            delete point;
        }
    }
}

// Draw a horizontal/vertical rectangle
void drawRectangle(PNG *png, HSLAPixel *color, Vertice a, Vertice b) {
    for (unsigned int y = std::min(a.y, b.y); y < std::max(a.y, b.y); y++) {
        Vertice *pointA = new Vertice(a.x, y);
        Vertice *pointB = new Vertice(b.x, y);
        drawLine(png, color, *pointA, *pointB);
        delete pointA;
        delete pointB;
    }
}

// Draw horizontal-bottom-triangle
void drawHBTriangle(PNG *png, HSLAPixel *color, Vertice point, Vertice left, Vertice right) {
    if (point.y < left.y) { // point is on the top
        for (unsigned int y = point.y; y < left.y; y++) {
            Vertice *pointA = pointOnLine(point, left, y);
            Vertice *pointB = pointOnLine(point, right, y);
            drawLine(png, color, *pointA, *pointB);
            delete pointA;
            delete pointB;
        }
    } else { // point is on the bottom
        for (unsigned int y = left.y; y < point.y; y++) {
            Vertice *pointA = pointOnLine(point, left, y);
            Vertice *pointB = pointOnLine(point, right, y);
            drawLine(png, color, *pointA, *pointB);
            delete pointA;
            delete pointB;
        }
    }
}

// Draw a random triangle
void drawTriangle(PNG *png, HSLAPixel *color, Vertice a, Vertice b, Vertice c) {
    Vertice *middle = new Vertice(0, 0);
    unsigned int minY = std::min({a.y, b.y, c.y});
    unsigned int maxY = std::max({a.y, b.y, c.y});
    if (a.y > minY && a.y < maxY) { // If a is middle point
        middle = pointOnLine(b, c, a.y);
        if (a.x < middle->x) { // HBTriangle need left, right
            drawHBTriangle(png, color, b, a, *middle);
            drawHBTriangle(png, color, c, a, *middle);
        } else {
            drawHBTriangle(png, color, b, *middle, a);
            drawHBTriangle(png, color, c, *middle, a);
        }
    } else if (b.y > minY && b.y < maxY) { // If b is middle point
        middle = pointOnLine(a, c, b.y);
        if (b.x < middle->x) {
            drawHBTriangle(png, color, a, b, *middle);
            drawHBTriangle(png, color, c, b, *middle);
        } else {
            drawHBTriangle(png, color, a, *middle, b);
            drawHBTriangle(png, color, c, *middle, b);
        }
    } else { // If c is middle point
        middle = pointOnLine(a, b, c.y);
        if (c.x < middle->x) {
            drawHBTriangle(png, color, b, c, *middle);
            drawHBTriangle(png, color, a, c, *middle);
        } else {
            drawHBTriangle(png, color, b, *middle, c);
            drawHBTriangle(png, color, a, *middle, c);
        }
    }
    delete middle;
}

// With all these tools I can finally draw my personal Logo
PNG myArt(unsigned int width, unsigned int height) {
    PNG png(width, height);
    HSLAPixel backgroundColor(0, 0, 0.94, 1.0);
    HSLAPixel frameColor(0, 0, 0.31, 1.0);
    HSLAPixel specialColor(218, 0.82, 0.61, 1.0);

    // Init picture with background color
    drawRectangle(&png, &backgroundColor, Vertice(0, 0), Vertice(width, height));

    // Draw the frame with frame color
    drawRectangle(&png, &frameColor, Vertice(width*0.250000, height*0.250000), Vertice(width*0.300000, height*0.750000));
    drawRectangle(&png, &frameColor, Vertice(width*0.300000, height*0.700000), Vertice(width*0.540981, height*0.750000));
    drawRectangle(&png, &frameColor, Vertice(width*0.300000, height*0.250000), Vertice(width*0.700000, height*0.300000));
    drawRectangle(&png, &frameColor, Vertice(width*0.700000, height*0.250000), Vertice(width*0.750000, height*0.471605));
    drawRectangle(&png, &frameColor, Vertice(width*0.452676, height*0.502230), Vertice(width*0.502230, height*0.669822));
    drawRectangle(&png, &frameColor, Vertice(width*0.601338, height*0.502230), Vertice(width*0.650893, height*0.750000));
    drawRectangle(&png, &frameColor, Vertice(width*0.650893, height*0.502230), Vertice(width*0.669822, height*0.551785));
    drawRectangle(&png, &frameColor, Vertice(width*0.681516, height*0.700000), Vertice(width*0.700000, height*0.750000));
    drawRectangle(&png, &frameColor, Vertice(width*0.700000, height*0.582408), Vertice(width*0.750000, height*0.750000));
    drawTriangle (&png, &frameColor, Vertice(width*0.540981, height*0.700000), Vertice(width*0.540981, height*0.750000), Vertice(width*0.570714, height*0.7500000));

    // Draw Special Color
    drawRectangle(&png, &specialColor, Vertice(width*0.700000, height*0.502230), Vertice(width*0.750000, height*0.551785));
    drawTriangle (&png, &specialColor, Vertice(width*0.502230, height*0.584819), Vertice(width*0.502230, height*0.502230), Vertice(width*0.601338, height*0.667409));
    drawTriangle (&png, &specialColor, Vertice(width*0.502230, height*0.584819), Vertice(width*0.601338, height*0.750000), Vertice(width*0.601338, height*0.667409));

    return png;
}
