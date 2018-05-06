// Animal.cpp
#include "Animal.h"

using namespace std;

Animal::Animal() {
    type_ = "cat";
    food_ = "fish";
}

Animal::Animal(string t, string f) {
    type_ = t;
    food_ = f;
}

string Animal::getType() {
    return type_;
}

void Animal::setType(string s) {
    type_ = s;
}

string Animal::getFood() {
    return food_;
}

void Animal::setFood(string s) {
    food_ = s;
}

string Animal::print() {
    string ret = "I am a " + type_ + ".";
    return ret;
}
