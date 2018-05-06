#include <iostream>
#include <string>
using namespace std;

#include "square.h"

Square::Square() {
    name = "mysquare";
    lengthptr = new double;
    *lengthptr = 2.0;
}

void Square::setName(string newName) {
  name = newName;
}

void Square::setLength(double newVal) {
  *lengthptr = newVal;
}

string Square::getName() const {
  return name;
}

double Square::getLength() const {
  return *lengthptr;
}

Square::Square(const Square & other) {
    name = other.getName();
    lengthptr = new double;
    *lengthptr = other.getLength();
}

Square::~Square() {
    delete lengthptr;
}

Square & Square::operator=(const Square & other) {
    name = other.name;
    lengthptr = new double;
    *lengthptr = *other.lengthptr;
    return *this;
}

Square Square::operator+(const Square & other) {
    Square * c = new Square();
    c->setName(this->name + other.name);
    c->setLength(*this->lengthptr + *other.lengthptr);
    return *c;
}
