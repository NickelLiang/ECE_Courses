// Pet.cpp
#include "Pet.h"

void Pet::setFood(string nu_food) {
    food_ = nu_food;
}

string Pet::getFood() {
    return food_;
}

void Pet::setName(string nu_name) {
    name_ = nu_name;
}

string Pet::getName() {
    return name_;
}

void Pet::setOwnerName(string nu_owner_name) {
    owner_name_ = nu_owner_name;
}

string Pet::getOwnerName() {
    return owner_name_;
}

string Pet::print() {
    return "My name is " + name_;
};

Pet::Pet() : Animal("cat", "fish"), name_("Fluffy"), owner_name_("Cinda") { }

Pet::Pet(string t, string f, string n, string o) : Animal(t, f), name_(n), owner_name_(o) { }
